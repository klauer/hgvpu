program recovery ("S={S}")

/*
 * 02/26/08 ses original code - recover from motor power loss
 */

option -c;       /* don't wait for all channels to connect */
/* option +r; */

%%#include	<string.h>
%%#include	<epicsThread.h>
%%#include	<epicsString.h>

/* These variables are CAM position rotary poteniometer read backs*/
float	Cam1Position;
assign	Cam1Position to "{S}:CM1READDEG";
float	Cam2Position;
assign	Cam2Position to "{S}:CM2READDEG";
float	Cam3Position;
assign	Cam3Position to "{S}:CM3READDEG";
float	Cam4Position;
assign	Cam4Position to "{S}:CM4READDEG";
float	Cam5Position;
assign	Cam5Position to "{S}:CM5READDEG";


/* These variables are Translation position linear potentiometer read backs */
float	Trans1Position;
assign	Trans1Position to "{S}:LP4POSCALC";
monitor	Trans1Position;
float	Trans2Position;
assign	Trans2Position to "{S}:LP8POSCALC";
monitor	Trans2Position;


/* These variables are used to manipulate the CAM motor records */
float	Cam1MotorSET;
assign	Cam1MotorSET to "{S}:CM1MOTOR.SET";
float	Cam2MotorSET;
assign	Cam2MotorSET to "{S}:CM2MOTOR.SET";
float	Cam3MotorSET;
assign	Cam3MotorSET to "{S}:CM3MOTOR.SET";
float	Cam4MotorSET;
assign	Cam4MotorSET to "{S}:CM4MOTOR.SET";
float	Cam5MotorSET;
assign	Cam5MotorSET to "{S}:CM5MOTOR.SET";

float	Cam1MotorVAL;
assign	Cam1MotorVAL to "{S}:CM1MOTOR.VAL";
float	Cam2MotorVAL;
assign	Cam2MotorVAL to "{S}:CM2MOTOR.VAL";
float	Cam3MotorVAL;
assign	Cam3MotorVAL to "{S}:CM3MOTOR.VAL";
float	Cam4MotorVAL;
assign	Cam4MotorVAL to "{S}:CM4MOTOR.VAL";
float	Cam5MotorVAL;
assign	Cam5MotorVAL to "{S}:CM5MOTOR.VAL";

float	Cam1MotorSTUP;
assign	Cam1MotorSTUP to "{S}:CM1MOTOR.STUP";
float	Cam2MotorSTUP;
assign	Cam2MotorSTUP to "{S}:CM2MOTOR.STUP";
float	Cam3MotorSTUP;
assign	Cam3MotorSTUP to "{S}:CM3MOTOR.STUP";
float	Cam4MotorSTUP;
assign	Cam4MotorSTUP to "{S}:CM4MOTOR.STUP";
float	Cam5MotorSTUP;
assign	Cam5MotorSTUP to "{S}:CM5MOTOR.STUP";

long	cam1EnableCtl;
assign	cam1EnableCtl to "{S}:CM1MOTOR.SPMG";
long	cam2EnableCtl;
assign	cam2EnableCtl to "{S}:CM2MOTOR.SPMG";
long	cam3EnableCtl;
assign	cam3EnableCtl to "{S}:CM3MOTOR.SPMG";
long	cam4EnableCtl;
assign	cam4EnableCtl to "{S}:CM4MOTOR.SPMG";
long	cam5EnableCtl;
assign	cam5EnableCtl to "{S}:CM5MOTOR.SPMG";


/* These variables are used to manipulate the Translation motor records */
float	Trans1MotorSET;
assign	Trans1MotorSET to "{S}:TM1MOTOR.SET";
float	Trans2MotorSET;
assign	Trans2MotorSET to "{S}:TM2MOTOR.SET";

float	Trans1MotorVAL;
assign	Trans1MotorVAL to "{S}:TM1MOTOR.VAL";
float	Trans2MotorVAL;
assign	Trans2MotorVAL to "{S}:TM2MOTOR.VAL";

float	Trans1MotorSTUP;
assign	Trans1MotorSTUP to "{S}:TM1MOTOR.STUP";
float	Trans2MotorSTUP;
assign	Trans2MotorSTUP to "{S}:TM2MOTOR.STUP";

long	trans1EnableCtl;
assign	trans1EnableCtl to "{S}:TM1MOTOR.SPMG";
long	trans2EnableCtl;
assign	trans2EnableCtl to "{S}:TM1MOTOR.SPMG";


/* This variable is used to trigger the recovery process */
short	recover;
assign	recover to "{S}:RCVERMOTRPOS";
monitor	recover;
short	recoverLvl1;
assign	recoverLvl1 to "{S}:RECOVERLEVL1";
monitor	recoverLvl1;
short	recoverLvl2;
assign	recoverLvl2 to "{S}:RECOVERLEVL2";
monitor	recoverLvl2;
short	ucmiLevel1Fault;
assign	ucmiLevel1Fault to "{S}:LEVEL1FAULTM";
monitor	ucmiLevel1Fault;
short	ucmiLevel2Fault;
assign	ucmiLevel2Fault to "{S}:LEVEL2FAULTM";
monitor	ucmiLevel2Fault;
long	excitationSTAT;
assign	excitationSTAT to "{S}:EXCTTNADCM.STAT";
monitor	excitationSTAT;
long	motorError;
assign	motorError to "{S}:MOTORERROR";
monitor	motorError;


/* These variables are used for informational messages during recovery */
string  recoverMsg1;
assign  recoverMsg1 to "{S}:RECOVERMSG1";

string  recoverMsg2;
assign  recoverMsg2 to "{S}:RECOVERMSG2";

short	recoverRequest;
short	moveTranslation;
long	commStatus;


ss powerRecovery
{
	state init
	{
		entry {
			recoverRequest = 0;
			moveTranslation = 0;
			Cam1MotorSTUP = 1;
			Cam2MotorSTUP = 1;
			Cam3MotorSTUP = 1;
			Cam4MotorSTUP = 1;
			Cam5MotorSTUP = 1;
			Trans1MotorSTUP = 1;
			Trans2MotorSTUP = 1;
		}
		when(1) {

		} state checkPVsConnected
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
		entry {

		}

		when(recover) {
			recoverRequest = 1;
			/* mask off communication errors for motors */
			commStatus = (motorError & 0x7F00);
		} state retrievePVdata
		
		when(recoverLvl1) {
		
		} state checkTranslationStage
		
		when(recoverLvl2) {
		
		} state checkTranslationStage
	}

	/*********************************/
	/*   save potentiometer values   */
	/*********************************/    
	state retrievePVdata
	{
		entry {

		}

		when(recoverRequest && (excitationSTAT == 0) && (commStatus == 0)) {
			/* retrieve the potentiometer read back values */
			pvGet(Cam1Position);
			pvGet(Cam2Position);
			pvGet(Cam3Position);
			pvGet(Cam4Position);
			pvGet(Cam5Position);
			pvGet(Trans1Position);
			pvGet(Trans2Position);
		} state restorePVdata
		
		when(recoverRequest && ((excitationSTAT == 1) || (commStatus == 1))) {
			sprintf(recoverMsg1, "Excitation voltage and/or Comm Error");
            pvPut(recoverMsg1);
            recoverRequest = 0;
		} state waitForCommand
	}

	/*********************************/
	/*   load potentiometer values   */
	/*********************************/    
	state restorePVdata
	{
		when(recoverRequest && (excitationSTAT == 0) && (commStatus == 0)) {
			/* get the new position values ready to write */
			Cam1MotorVAL = Cam1Position;
			Cam2MotorVAL = Cam2Position;
			Cam3MotorVAL = Cam3Position;
			Cam4MotorVAL = Cam4Position;
			Cam5MotorVAL = Cam5Position;
			Trans1MotorVAL = Trans1Position;
			Trans2MotorVAL = Trans2Position;

			/* put all motors in "Go" mode to enable position update */
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
			
			/* force a motor status update */
			pvPut(Cam1MotorSTUP);
			pvPut(Cam2MotorSTUP);
			pvPut(Cam3MotorSTUP);
			pvPut(Cam4MotorSTUP);
			pvPut(Cam5MotorSTUP);
			pvPut(Trans1MotorSTUP);
			pvPut(Trans2MotorSTUP);
%%			epicsThreadSleep(1);
			
			/* put the motor records into Calibration "Set" mode */
			Cam1MotorSET = 1;
			Cam2MotorSET = 1;
			Cam3MotorSET = 1;
			Cam4MotorSET = 1;
			Cam5MotorSET = 1;
			Trans1MotorSET = 1;
			Trans2MotorSET = 1;
			pvPut(Cam1MotorSET);
			pvPut(Cam2MotorSET);
			pvPut(Cam3MotorSET);
			pvPut(Cam4MotorSET);
			pvPut(Cam5MotorSET);
			pvPut(Trans1MotorSET);
			pvPut(Trans2MotorSET);
			
			/* store the new motor positions */
			pvPut(Cam1MotorVAL);
			pvPut(Cam2MotorVAL);
			pvPut(Cam3MotorVAL);
			pvPut(Cam4MotorVAL);
			pvPut(Cam5MotorVAL);
			pvPut(Trans1MotorVAL);
			pvPut(Trans2MotorVAL);

			/* put the motor records into Calibration "Use" mode */
			Cam1MotorSET = 0;
			Cam2MotorSET = 0;
			Cam3MotorSET = 0;
			Cam4MotorSET = 0;
			Cam5MotorSET = 0;
			Trans1MotorSET = 0;
			Trans2MotorSET = 0;
			pvPut(Cam1MotorSET);
			pvPut(Cam2MotorSET);
			pvPut(Cam3MotorSET);
			pvPut(Cam4MotorSET);
			pvPut(Cam5MotorSET);
			pvPut(Trans1MotorSET);
			pvPut(Trans2MotorSET);

			/* force a motor status update */
			pvPut(Cam1MotorSTUP);
			pvPut(Cam2MotorSTUP);
			pvPut(Cam3MotorSTUP);
			pvPut(Cam4MotorSTUP);
			pvPut(Cam5MotorSTUP);
			pvPut(Trans1MotorSTUP);
			pvPut(Trans2MotorSTUP);
			recoverRequest = 0;
%%			epicsThreadSleep(1);
		} state waitForCommand

		when(recoverRequest && ((excitationSTAT == 1) || (commStatus == 1))) {
			sprintf(recoverMsg1, "ERROR: Cannot recover positions.");
            pvPut(recoverMsg1);
            sprintf(recoverMsg2, "Excitation voltage and/or Comm Error");
            pvPut(recoverMsg2);
			recoverRequest = 0;
		} state waitForCommand
	}

	/********************************/
	/*   check translation stages   */
	/********************************/    
	state checkTranslationStage
	{
		entry {

		}

		when(recoverLvl1 && (ucmiLevel1Fault == 1)) {
			moveTranslation = 1;
		} state fixLevelFault
		
		when(recoverLvl2 && (ucmiLevel2Fault == 1)) {
			moveTranslation = 1;
		} state fixLevelFault

		when(recoverLvl1 && (ucmiLevel1Fault == 0)) {
			/* do nothing, no fault indicated */
		} state waitForCommand

		when(recoverLvl2 && (ucmiLevel2Fault == 0)) {
			/* do nothing, no fault indicated */
		} state waitForCommand

	}

	/*****************************************************/
	/*   fix level 1/2 fault - move translation stages   */
	/*****************************************************/
	state fixLevelFault
	{
		entry {

		}

		when(moveTranslation && (excitationSTAT == 0) && (commStatus == 0)) {
			/* move translation stage with farther position to match the closer position */
			pvGet(Trans1MotorVAL);
			pvGet(Trans2MotorVAL);
			if((Trans1MotorVAL > 0) && (Trans2MotorVAL > 0)) {
				if(Trans1MotorVAL < Trans2MotorVAL) {
					Trans2MotorVAL = Trans1MotorVAL;
        	    	pvPut(Trans2MotorVAL);
				}
				else {
					Trans1MotorVAL = Trans2MotorVAL;
            		pvPut(Trans1MotorVAL);
	            }
    	        moveTranslation = 0;
			}
		} state waitForCommand
	}
}
