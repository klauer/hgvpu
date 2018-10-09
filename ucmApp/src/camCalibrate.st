program camCal ("S={S}")

/*
 * 11/28/07 ses original code - for calibrating CAM mover
 */

option -c;       /* don't wait for all channels to connect */
/* option +r; */

%%#include <string.h>
%%#include <epicsStdio.h>
%%#include <epicsString.h>
%%#include <epicsThread.h>
%%#include <epicsMath.h>
%%#include "waveformRecord.h"

%%# define	TIMEOUT		10

int32_t camCalAbort;
assign	camCalAbort "{S}:CALABORT";
monitor camCalAbort;

/* These variables are used to detect which CAM to calibrate */
short	calCam1;
assign	calCam1 to "{S}:CALCAM1C";
monitor	calCam1;

short	calCam2;
assign	calCam2 to "{S}:CALCAM2C";
monitor	calCam2;

short	calCam3;
assign	calCam3 to "{S}:CALCAM3C";
monitor	calCam3;

short	calCam4;
assign	calCam4 to "{S}:CALCAM4C";
monitor	calCam4;

short	calCam5;
assign	calCam5 to "{S}:CALCAM5C";
monitor	calCam5;

/* These variables are used to indicate which CAM is calibrating */
short	calCam1M;
assign	calCam1M to "{S}:CALCAM1M";
monitor	calCam1M;

short	calCam2M;
assign	calCam2M to "{S}:CALCAM2M";
monitor	calCam2M;

short	calCam3M;
assign	calCam3M to "{S}:CALCAM3M";
monitor	calCam3M;

short	calCam4M;
assign	calCam4M to "{S}:CALCAM4M";
monitor	calCam4M;

short	calCam5M;
assign	calCam5M to "{S}:CALCAM5M";
monitor	calCam5M;

/* These variables are used to disable all other motion during CAM calibration */
int32_t cam1EnableCtl;
assign	cam1EnableCtl to "{S}:CM1MOTOR.SPMG";

int32_t cam2EnableCtl;
assign	cam2EnableCtl to "{S}:CM2MOTOR.SPMG";

int32_t cam3EnableCtl;
assign	cam3EnableCtl to "{S}:CM3MOTOR.SPMG";

int32_t cam4EnableCtl;
assign	cam4EnableCtl to "{S}:CM4MOTOR.SPMG";

int32_t cam5EnableCtl;
assign	cam5EnableCtl to "{S}:CM5MOTOR.SPMG";

int32_t trans1EnableCtl;
assign	trans1EnableCtl to "{S}:TM1MOTOR.SPMG";

int32_t trans2EnableCtl;
assign	trans2EnableCtl to "{S}:TM1MOTOR.SPMG";


/* This variable is used to move a CAM during calibration */
float	camMotor;
assign  camMotor "";


/* This variable is used to monitor a CAM during calibration */
float	camReadback;
assign	camReadback "";
monitor	camReadback;


/* This variable is used to readback the current value of a rotary potentiometer */
double	rotaryPot;
assign	rotaryPot "";
monitor rotaryPot;


/* These variables are used to readback the current value of a linear potentiometer */
double	linearPot1;
assign	linearPot1 to "{S}:LP1ADCM";
monitor	linearPot1;

double	linearPot2;
assign	linearPot2 to "{S}:LP2ADCM";
monitor	linearPot2;

double	linearPot3;
assign	linearPot3 to "{S}:LP3ADCM";
monitor	linearPot3;

double	linearPot5;
assign	linearPot5 to "{S}:LP5ADCM";
monitor	linearPot5;

double	linearPot6;
assign	linearPot6 to "{S}:LP6ADCM";
monitor	linearPot6;

double	linearPot7;
assign	linearPot7 to "{S}:LP7ADCM";
monitor	linearPot7;


/* These variables are used for informational messages during calibrations */
string  calMsg1;
assign  calMsg1 to "{S}:CALMSG1";

string  calMsg2;
assign  calMsg2 to "{S}:CALMSG2";

string  calMsg3;
assign  calMsg3 to "{S}:CALMSG3";


/* These variables are used to store the ADC data read during calibration */
float	voltage;
assign	voltage to "{S}:EXCTTNADCM";
float	voltageAvg;
assign	voltageAvg to "{S}:CALVOLTAVG";
float	camAngle[180];
assign	camAngle to "{S}:CALCAMANGLE";
double	camPotentiometer[180];
assign	camPotentiometer to "{S}:CALCAMPOT";
double	girderPotentiometer1[180];
assign	girderPotentiometer1 to "{S}:CALGDRPOT1";
double	girderPotentiometer2[180];
assign	girderPotentiometer2 to "{S}:CALGDRPOT2";
double	girderPotentiometer3[180];
assign	girderPotentiometer3 to "{S}:CALGDRPOT3";
double	girderPotentiometer5[180];
assign	girderPotentiometer5 to "{S}:CALGDRPOT5";
double	girderPotentiometer6[180];
assign	girderPotentiometer6 to "{S}:CALGDRPOT6";
double	girderPotentiometer7[180];
assign	girderPotentiometer7 to "{S}:CALGDRPOT7";

short	i;
float	voltageSrc[180];
float	voltageSum;
char*	pvPrefix;
string	pvName;

ss camCal
{
	state init
	{
		entry {
			pvPrefix = epicsStrDup(macValueGet("S"));
		}
		when(1) {

		} state waitForCommand
	}

	/********************************/
	/*   check for connected pv's   */
	/********************************/    
	state checkPVsConnected
	{
		when(pvConnectCount() != pvChannelCount()) {
%%			epicsThreadSleep(5);
		} state checkPVsConnected

		when(pvConnectCount() == pvChannelCount()) {
%%			epicsThreadSleep(1);
		} state waitForCommand
	}

	/**************************/
	/*   wait for a command   */
	/**************************/
	state waitForCommand
	{
		/* Enable all other motors after CAM1 calibration process */
		entry {
			cam1EnableCtl = 3;
			cam2EnableCtl = 3;
			cam3EnableCtl = 3;
			cam4EnableCtl = 3;
			cam5EnableCtl = 3;
			trans1EnableCtl = 3;
			trans2EnableCtl = 3;
			pvPut(cam1EnableCtl);
			pvPut(cam2EnableCtl);
			pvPut(cam3EnableCtl);
			pvPut(cam4EnableCtl);
			pvPut(cam5EnableCtl);
			pvPut(trans1EnableCtl);
			pvPut(trans2EnableCtl);
		}

		when(calCam1) {
			/* received a calibrate CAM1 command */
			calCam1 = 0;
			pvPut(calCam1);
			calCam1M = 1;
			pvPut(calCam1M);
			sprintf(calMsg1, "Initializing CAM1");
            		pvPut(calMsg1);
			strcpy(calMsg2, "");
			pvPut(calMsg2);
			strcpy(calMsg3, "");
			pvPut(calMsg3);
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM1MOTOR.VAL");
			pvAssign(camMotor, pvName); 
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM1MOTOR.RBV");
			pvAssign(camReadback, pvName);
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM1ADCM");
			pvAssign(rotaryPot, pvName);
			cam1EnableCtl = 3;
			cam2EnableCtl = 0;
			cam3EnableCtl = 0;
			cam4EnableCtl = 0;
			cam5EnableCtl = 0;
		} state waitForPVconnect

		when(calCam2) {
			/* received a calibrate CAM2 command */
			calCam2 = 0;
			pvPut(calCam2);
			calCam2M = 1;
			pvPut(calCam2M);
			sprintf(calMsg1, "Initializing CAM2");
            		pvPut(calMsg1);
			strcpy(calMsg2, "");
			pvPut(calMsg2);
			strcpy(calMsg3, "");
			pvPut(calMsg3);
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM2MOTOR.VAL");
			pvAssign(camMotor, pvName); 
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM2MOTOR.RBV");
			pvAssign(camReadback, pvName);
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM2ADCM");
			pvAssign(rotaryPot, pvName);
			cam1EnableCtl = 0;
			cam2EnableCtl = 3;
			cam3EnableCtl = 0;
			cam4EnableCtl = 0;
			cam5EnableCtl = 0;
		} state waitForPVconnect

		when(calCam3) {
			/* received a calibrate CAM3 command */
			calCam3 = 0;
			pvPut(calCam3);
			calCam3M = 1;
			pvPut(calCam3M);
			sprintf(calMsg1, "Initializing CAM3");
            		pvPut(calMsg1);
			strcpy(calMsg2, "");
			pvPut(calMsg2);
			strcpy(calMsg3, "");
			pvPut(calMsg3);
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM3MOTOR.VAL");
			pvAssign(camMotor, pvName); 
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM3MOTOR.RBV");
			pvAssign(camReadback, pvName);
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM3ADCM");
			pvAssign(rotaryPot, pvName);
			cam1EnableCtl = 0;
			cam2EnableCtl = 0;
			cam3EnableCtl = 3;
			cam4EnableCtl = 0;
			cam5EnableCtl = 0;
		} state waitForPVconnect

		when(calCam4) {
			/* received a calibrate CAM4 command */
			calCam4 = 0;
			pvPut(calCam4);
			calCam4M = 1;
			pvPut(calCam4M);
			sprintf(calMsg1, "Initializing CAM4");
            		pvPut(calMsg1);
			strcpy(calMsg2, "");
			pvPut(calMsg2);
			strcpy(calMsg3, "");
			pvPut(calMsg3);
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM4MOTOR.VAL");
			pvAssign(camMotor, pvName); 
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM4MOTOR.RBV");
			pvAssign(camReadback, pvName);
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM4ADCM");
			pvAssign(rotaryPot, pvName);
			cam1EnableCtl = 0;
			cam2EnableCtl = 0;
			cam3EnableCtl = 0;
			cam4EnableCtl = 3;
			cam5EnableCtl = 0;
		} state waitForPVconnect

		when(calCam5) {
			/* received a calibrate CAM5 command */
			calCam5 = 0;
			pvPut(calCam5);
			calCam5M = 1;
			pvPut(calCam5M);
			sprintf(calMsg1, "Initializing CAM1");
            		pvPut(calMsg1);
			strcpy(calMsg2, "");
			pvPut(calMsg2);
			strcpy(calMsg3, "");
			pvPut(calMsg3);
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM5MOTOR.VAL");
			pvAssign(camMotor, pvName); 
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM5MOTOR.RBV");
			pvAssign(camReadback, pvName);
			strcpy(pvName, pvPrefix);
			strcat(pvName, ":CM5ADCM");
			pvAssign(rotaryPot, pvName);
			cam1EnableCtl = 0;
			cam2EnableCtl = 0;
			cam3EnableCtl = 0;
			cam4EnableCtl = 0;
			cam5EnableCtl = 3;
		} state waitForPVconnect
	}

	/************************/
	/*   waitForPVconnect   */
	/************************/
	state waitForPVconnect
	{
		/* Wait for a while to allow pv's to connect */
		when(pvConnected(camMotor) 
		  && pvConnected(camReadback)
		  && pvConnected(rotaryPot)) {
			/* Dynamic pv assignments have connected */
			sprintf(calMsg2, "Moving motor to 0 degrees");
			pvPut(calMsg2);
			camMotor = 0.0;
			pvPut(camMotor);
		} state zeroCAM
		
		when(delay(TIMEOUT)) {
			/* Could not connect to PV's */
			strcpy(calMsg1, "Could not connect to PV's");
            pvPut(calMsg1);
			sprintf(calMsg2, "Timeout: Aborting Calibration");
			pvPut(calMsg2);
			strcpy(calMsg3,"");
			pvPut(calMsg3);
			calCam1M = 0;
			calCam2M = 0;
			calCam3M = 0;
			calCam4M = 0;
			calCam5M = 0;
			pvPut(calCam1M);
			pvPut(calCam2M);
			pvPut(calCam3M);
			pvPut(calCam4M);
			pvPut(calCam5M);
		} state waitForCommand
	}

	/************************/
	/*       zero CAM       */
	/************************/
	state zeroCAM
	{
		/* Move CAMx to 0 degrees */
		when(fabs(camReadback-camMotor) < 0.01) {
			/* Motor reached 0.0 degrees */
		} state calCAMx
		
		when(delay(TIMEOUT)) {
			/* CAMx has not moved to 0 degrees */
			strcpy(calMsg1, "Motor did not move to 0 degrees");
            pvPut(calMsg1);
			sprintf(calMsg2, "Motor Timeout: Aborting Calibration");
			pvPut(calMsg2);
			strcpy(calMsg3,"");
			pvPut(calMsg3);
		} state waitForCommand
	}

	/************************/
	/*   calibrate CAMx     */
	/************************/
	state calCAMx
	{
		when(1) {
			/* Disable all other motors during CAMx calibration process */
			trans1EnableCtl = 0;
			trans2EnableCtl = 0;
			pvPut(cam1EnableCtl);
			pvPut(cam2EnableCtl);
			pvPut(cam3EnableCtl);
			pvPut(cam4EnableCtl);
			pvPut(cam5EnableCtl);
			pvPut(trans1EnableCtl);
			pvPut(trans2EnableCtl);
			sprintf(calMsg1, "Calibrating CAM");
            pvPut(calMsg1);
			sprintf(calMsg2, "Measuring Gain/Offset");
            pvPut(calMsg2);
			i = 0;
			voltageAvg = 0.0;
			voltageSum = 0.0;
		} state checkAbortCAMx
	}

	/************************/
	/*  check abort CAMx    */
	/************************/
	state checkAbortCAMx
	{
		/* Check if abort button pushed */
		when(camCalAbort) {
			camCalAbort = 0;
			pvPut(camCalAbort);
			strcpy(calMsg1, "");
            pvPut(calMsg1);
			sprintf(calMsg2, "Abort Command Received");
            pvPut(calMsg2);
            strcpy(calMsg3,"");
            pvPut(calMsg3);
			calCam1M = 0;
			calCam2M = 0;
			calCam3M = 0;
			calCam4M = 0;
			calCam5M = 0;
			pvPut(calCam1M);
			pvPut(calCam2M);
			pvPut(calCam3M);
			pvPut(calCam4M);
			pvPut(calCam5M);
		} state waitForCommand
		
		when(TRUE) {
			/* go ahead and move motor */
		} state moveCAMx
	}

	/************************/
	/*       move CAMx      */
	/************************/
	state moveCAMx
	{
		/* Rotate 360 degrees (2 degree increments) */
		when(i < 180) {
			camAngle[i] = i * 2;
			camMotor = camAngle[i];
			sprintf(calMsg3, "%.1f degrees", camAngle[i]);
           	pvPut(calMsg3);
			pvPut(camMotor);
		} state checkCAMx
		
		when(i == 180) {
			/* CamX has moved 360 degrees */
			camMotor = 360;
			pvPut(camMotor);
		} state calculate
	}

	/************************/
	/*      check CAMx      */
	/************************/
	state checkCAMx
	{
		/* Check if motor reached setpoint */
		when(fabs(camMotor - camReadback) < 0.01) {
			/* motor reached setpoint */
		} state readADCx
		
		when(delay(TIMEOUT)) {
			strcpy(calMsg1, "");
            pvPut(calMsg1);
			sprintf(calMsg2, "Motor Timeout: Aborting Calibration");
			pvPut(calMsg2);
			strcpy(calMsg3,"");
			pvPut(calMsg3);
			calCam1M = 0;
			calCam2M = 0;
			calCam3M = 0;
			calCam4M = 0;
			calCam5M = 0;
			pvPut(calCam1M);
			pvPut(calCam2M);
			pvPut(calCam3M);
			pvPut(calCam4M);
			pvPut(calCam5M);
		} state waitForCommand	
	}

	/************************/
	/*       read ADCx      */
	/************************/
	state readADCx
	{
		/* Read potentiometer values*/
		when(delay(1.1)) {
			pvGet(voltage);
			voltageSrc[i] = voltage;
			voltageSum = voltageSum + voltage;
			pvGet(rotaryPot);
			camPotentiometer[i] = rotaryPot;
			pvGet(linearPot1);
			girderPotentiometer1[i] = linearPot1;
			pvGet(linearPot2);
			girderPotentiometer2[i] = linearPot2;
			pvGet(linearPot3);
			girderPotentiometer3[i] = linearPot3;
			pvGet(linearPot5);
			girderPotentiometer5[i] = linearPot5;
			pvGet(linearPot6);
			girderPotentiometer6[i] = linearPot6;
			pvGet(linearPot7);
			girderPotentiometer7[i] = linearPot7;
			i++;
		} state checkAbortCAMx
	}

	/*******************************/
	/*    calculate avg voltage    */
	/*******************************/
	state calculate
	{
		when(1) {	
			/* Calculate average voltage source measurement during calibration */
			voltageAvg = voltageSum/i;
		} state storeData
	}

	/************************/
	/*    store pv data     */
	/************************/
	state storeData
	{
		when(1) {	
			/* Write collected data to process variables (waveform records) */
			sprintf(calMsg2, "Import Data into Octave");
            pvPut(calMsg2);
            strcpy(calMsg3,"");
            pvPut(calMsg3);
            pvPut(voltageAvg);
			pvPut(camAngle);
			pvPut(camPotentiometer);
			pvPut(girderPotentiometer1);
			pvPut(girderPotentiometer2);
			pvPut(girderPotentiometer3);
			pvPut(girderPotentiometer5);
			pvPut(girderPotentiometer6);
			pvPut(girderPotentiometer7);
			calCam1M = 0;
			calCam2M = 0;
			calCam3M = 0;
			calCam4M = 0;
			calCam5M = 0;
			pvPut(calCam1M);
			pvPut(calCam2M);
			pvPut(calCam3M);
			pvPut(calCam4M);
			pvPut(calCam5M);
		} state waitForCommand
	}
}
