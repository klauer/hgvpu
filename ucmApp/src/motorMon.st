program motorMon ("S={S}")

/*
 * 03/06/08 ses original code - monitoring motor positions
 */

option -c;       /* don't wait for all channels to connect */
/* option +r; */

%%#include <string.h>
%%#include <epicsThread.h>
%%#include <epicsString.h>
%%#include <epicsMath.h>

/* These variables are CAM position rotary poteniometer read backs*/
float	Cam1Position;
assign	Cam1Position to "{S}:CM1READDEG";
monitor Cam1Position;
float	Cam2Position;
assign	Cam2Position to "{S}:CM2READDEG";
monitor Cam2Position;
float	Cam3Position;
assign	Cam3Position to "{S}:CM3READDEG";
monitor	Cam3Position;
float	Cam4Position;
assign	Cam4Position to "{S}:CM4READDEG";
monitor	Cam4Position;
float	Cam5Position;
assign	Cam5Position to "{S}:CM5READDEG";
monitor	Cam5Position;


/* These variables are Translation position linear potentiometer read backs */
float	Trans1Position;
assign	Trans1Position to "{S}:LP4POSCALC";
monitor	Trans1Position;
float	Trans2Position;
assign	Trans2Position to "{S}:LP8POSCALC";
monitor	Trans2Position;


/* These variables are CAM position motor read backs */
float	Cam1MotorRBV;
assign	Cam1MotorRBV to "{S}:CM1MOTOR.RBV";
monitor	Cam1MotorRBV;
float	Cam2MotorRBV;
assign	Cam2MotorRBV to "{S}:CM2MOTOR.RBV";
monitor	Cam2MotorRBV;
float	Cam3MotorRBV;
assign	Cam3MotorRBV to "{S}:CM3MOTOR.RBV";
monitor	Cam3MotorRBV;
float	Cam4MotorRBV;
assign	Cam4MotorRBV to "{S}:CM4MOTOR.RBV";
monitor	Cam4MotorRBV;
float	Cam5MotorRBV;
assign	Cam5MotorRBV to "{S}:CM5MOTOR.RBV";
monitor	Cam5MotorRBV;

/* These variables enable a status update from the motors */
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


/* These variables are TRANSLATION position motor read backs */
float	Trans1MotorRBV;
assign	Trans1MotorRBV to "{S}:TM1MOTOR.RBV";
monitor	Trans1MotorRBV;
float	Trans2MotorRBV;
assign	Trans2MotorRBV to "{S}:TM2MOTOR.RBV";
monitor	Trans2MotorRBV;

/* These variables enable a status update from the motors */
float	Trans1MotorSTUP;
assign	Trans1MotorSTUP to "{S}:TM1MOTOR.STUP";
float	Trans2MotorSTUP;
assign	Trans2MotorSTUP to "{S}:TM2MOTOR.STUP";

/* These variables are to control the motor states */
float  Trans1MotorSPMG;
assign Trans1MotorSPMG to "{S}:TM1MOTOR.SPMG";
float  Trans2MotorSPMG;
assign Trans2MotorSPMG to "{S}:TM2MOTOR.SPMG";

/**************************************************************/
/* These variables indicate the current status for the motors */
/*															  */
/* status values:	0 = Normal								  */
/*					1 = Comm Error							  */
/*					2 = Position Error						  */
/*					3 = Override							  */
/**************************************************************/
short	Cam1motorStatus;
assign	Cam1motorStatus to "{S}:CM1MOTORSTAT";
monitor	Cam1motorStatus;

short	Cam2motorStatus;
assign	Cam2motorStatus to "{S}:CM2MOTORSTAT";
monitor	Cam2motorStatus;

short	Cam3motorStatus;
assign	Cam3motorStatus to "{S}:CM3MOTORSTAT";
monitor	Cam3motorStatus;

short	Cam4motorStatus;
assign	Cam4motorStatus to "{S}:CM4MOTORSTAT";
monitor	Cam4motorStatus;

short	Cam5motorStatus;
assign	Cam5motorStatus to "{S}:CM5MOTORSTAT";
monitor	Cam5motorStatus;

short	Trans1motorStatus;
assign	Trans1motorStatus to "{S}:TM1MOTORSTAT";
monitor	Trans1motorStatus;

short	Trans2motorStatus;
assign	Trans2motorStatus to "{S}:TM2MOTORSTAT";
monitor	Trans2motorStatus;


/* These variables are used to monitor if any motor is moving */
short	camMotorMoving;
assign	camMotorMoving to "{S}:CAMSMOVINGM";
monitor camMotorMoving;
short	transMotorMoving;
assign	transMotorMoving to "{S}:TRANSMOVINGM";
monitor transMotorMoving;


/* Setup monitors for all motor alarms (loss of communications) */
long 	Cam1MotorSTAT;
assign 	Cam1MotorSTAT to "{S}:CM1MOTOR.STAT";
monitor Cam1MotorSTAT;
evflag 	Cam1MotorSTATev;
sync 	Cam1MotorSTAT Cam1MotorSTATev;

long 	Cam2MotorSTAT;
assign 	Cam2MotorSTAT to "{S}:CM2MOTOR.STAT";
monitor	Cam2MotorSTAT;
evflag 	Cam2MotorSTATev;
sync 	Cam2MotorSTAT Cam2MotorSTATev;

long 	Cam3MotorSTAT;
assign 	Cam3MotorSTAT to "{S}:CM3MOTOR.STAT";
monitor Cam3MotorSTAT;
evflag 	Cam3MotorSTATev;
sync 	Cam3MotorSTAT Cam3MotorSTATev;

long 	Cam4MotorSTAT;
assign 	Cam4MotorSTAT to "{S}:CM4MOTOR.STAT";
monitor Cam4MotorSTAT;
evflag 	Cam4MotorSTATev;
sync 	Cam4MotorSTAT Cam4MotorSTATev;

long 	Cam5MotorSTAT;
assign 	Cam5MotorSTAT to "{S}:CM5MOTOR.STAT";
monitor Cam5MotorSTAT;
evflag 	Cam5MotorSTATev;
sync 	Cam5MotorSTAT Cam5MotorSTATev;

long 	Trans1MotorSTAT;
assign 	Trans1MotorSTAT to "{S}:TM1MOTOR.STAT";
monitor Trans1MotorSTAT;
evflag 	Trans1MotorSTATev;
sync 	Trans1MotorSTAT Trans1MotorSTATev;

long 	Trans2MotorSTAT;
assign 	Trans2MotorSTAT to "{S}:TM2MOTOR.STAT";
monitor Trans2MotorSTAT;
evflag 	Trans2MotorSTATev;
sync 	Trans2MotorSTAT Trans2MotorSTATev;


/* These variables are the maximum allowable position differences */
float	allowableCamDiff;
assign	allowableCamDiff to "{S}:CMXPOSTOLRNC";
monitor	allowableCamDiff;
float	allowableTransDiff;
assign	allowableTransDiff to "{S}:TMXPOSTOLRNC";
monitor	allowableTransDiff;


/* These variables are used to indicate current failures */
short	Cam1posError;
assign	Cam1posError to "{S}:MOTORERROR.B0";
short	Cam2posError;
assign	Cam2posError to "{S}:MOTORERROR.B1";
short	Cam3posError;
assign	Cam3posError to "{S}:MOTORERROR.B2";
short	Cam4posError;
assign	Cam4posError to "{S}:MOTORERROR.B3";
short	Cam5posError;
assign	Cam5posError to "{S}:MOTORERROR.B4";
short	Trans1posError;
assign	Trans1posError to "{S}:MOTORERROR.B5";
short	Trans2posError;
assign	Trans2posError to "{S}:MOTORERROR.B6";
short	Cam1comError;
assign	Cam1comError to "{S}:MOTORERROR.B8";
short	Cam2comError;
assign	Cam2comError to "{S}:MOTORERROR.B9";
short	Cam3comError;
assign	Cam3comError to "{S}:MOTORERROR.BA";
short	Cam4comError;
assign	Cam4comError to "{S}:MOTORERROR.BB";
short	Cam5comError;
assign	Cam5comError to "{S}:MOTORERROR.BC";
short	Trans1comError;
assign	Trans1comError to "{S}:MOTORERROR.BD";
short	Trans2comError;
assign	Trans2comError to "{S}:MOTORERROR.BE";


/* These variable is used to monitor the potentiometer excitation voltage */
float	excitationVoltage;
assign	excitationVoltage to "{S}:EXCTTNADCM";
monitor	excitationVoltage;

long	excitationSTAT;
assign	excitationSTAT to "{S}:EXCTTNADCM.STAT";
monitor	excitationSTAT;


/* These variables are used internally for the previous alarm state */
short	Cam1prevAlarmState;
short	Cam2prevAlarmState;
short	Cam3prevAlarmState;
short	Cam4prevAlarmState;
short	Cam5prevAlarmState;
short	Trans1prevAlarmState;
short	Trans2prevAlarmState;
short	excitationPrevAlarmState;

/* These variables set and monitor if the smart monitors are enabled/disabled */
short	smartMonitorCtl;
assign	smartMonitorCtl to "{S}:SMRTMONITORC";
monitor	smartMonitorCtl;
short	smartMonitorStatus;
assign	smartMonitorStatus to "{S}:SMRTMONITORM";
monitor	smartMonitorStatus;

/* These variables are used to stop the Cam/Translation/or Both groups of motors */
short	stopMotors;
assign	stopMotors to "{S}:STOPMOTORSC.PROC";
short	stopCamMotors;
assign	stopCamMotors to "{S}:CMXSTPMOTRSC.PROC";
short	stopTransMotors;
assign	stopTransMotors to "{S}:TMXSTPMOTRSC.PROC";


/* These variables are used to override specific motor error states */
short	Cam1motionOverride;
assign	Cam1motionOverride to "{S}:CM1MTNOVRRDC";
monitor	Cam1motionOverride;
short	Cam1motionOverridden;

short	Cam2motionOverride;
assign	Cam2motionOverride to "{S}:CM2MTNOVRRDC";
monitor	Cam2motionOverride;
short	Cam2motionOverridden;

short	Cam3motionOverride;
assign	Cam3motionOverride to "{S}:CM3MTNOVRRDC";
monitor	Cam3motionOverride;
short	Cam3motionOverridden;

short	Cam4motionOverride;
assign	Cam4motionOverride to "{S}:CM4MTNOVRRDC";
monitor	Cam4motionOverride;
short	Cam4motionOverridden;

short	Cam5motionOverride;
assign	Cam5motionOverride to "{S}:CM5MTNOVRRDC";
monitor	Cam5motionOverride;
short	Cam5motionOverridden;

short	Trans1motionOverride;
assign	Trans1motionOverride to "{S}:TM1MTNOVRRDC";
monitor	Trans1motionOverride;
short	Trans1motionOverridden;

short	Trans2motionOverride;
assign	Trans2motionOverride to "{S}:TM2MTNOVRRDC";
monitor	Trans2motionOverride;
short	Trans2motionOverridden;


char*	pvPrefix;


ss motorMon
{
	state init
	{
		entry {
			pvPrefix = epicsStrDup(macValueGet("S"));
			Cam1MotorSTUP = 1;
			Cam2MotorSTUP = 1;
			Cam3MotorSTUP = 1;
			Cam4MotorSTUP = 1;
			Cam5MotorSTUP = 1;
			Trans1MotorSTUP = 1;
			Trans2MotorSTUP = 1;
			efClear(Cam1MotorSTATev);
			efClear(Cam2MotorSTATev);
			efClear(Cam3MotorSTATev);
			efClear(Cam4MotorSTATev);
			efClear(Cam5MotorSTATev);
			efClear(Trans1MotorSTATev);
			efClear(Trans2MotorSTATev);
			Cam1posError = 0;
			Cam2posError = 0;
			Cam3posError = 0;
			Cam4posError = 0;
			Cam5posError = 0;
			Trans1posError = 0;
			Trans2posError = 0;
			pvPut(Cam1posError);
			pvPut(Cam2posError);
			pvPut(Cam3posError);
			pvPut(Cam4posError);
			pvPut(Cam5posError);
			pvPut(Trans1posError);
			pvPut(Trans2posError);
			Cam1comError = 0;
			Cam2comError = 0;
			Cam3comError = 0;
			Cam4comError = 0;
			Cam5comError = 0;
			Trans1comError = 0;
			Trans2comError = 0;
			pvPut(Cam1comError);
			pvPut(Cam2comError);
			pvPut(Cam3comError);
			pvPut(Cam4comError);
			pvPut(Cam5comError);
			pvPut(Trans1comError);
			pvPut(Trans2comError);
			Cam1motorStatus = 0;
			Cam2motorStatus = 0;
			Cam3motorStatus = 0;
			Cam4motorStatus = 0;
			Cam5motorStatus = 0;
			Trans1motorStatus = 0;
			Trans2motorStatus = 0;
			pvPut(Cam1motorStatus);
			pvPut(Cam2motorStatus);
			pvPut(Cam3motorStatus);
			pvPut(Cam4motorStatus);
			pvPut(Cam5motorStatus);
			pvPut(Trans1motorStatus);
			pvPut(Trans2motorStatus);
			Cam1prevAlarmState = -1;
			Cam2prevAlarmState = -1;
			Cam3prevAlarmState = -1;
			Cam4prevAlarmState = -1;
			Cam5prevAlarmState = -1;
			Trans1prevAlarmState = -1;
			Trans2prevAlarmState = -1;
			excitationPrevAlarmState = -1;
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
		} state waitForIssue
	}

	/*************************/
	/*   wait for an issue   */
	/*************************/
	state waitForIssue
	{
		entry {

		}

		when (!smartMonitorCtl) {
			smartMonitorStatus = 0;				/* turn smart monitor status "Off" */
			pvPut(smartMonitorStatus);
		} state ignoreSmartMonitors

		when (delay(10)) {
			if(camMotorMoving==0) {
				pvPut(Cam1MotorSTUP);
				pvPut(Cam2MotorSTUP);
				pvPut(Cam3MotorSTUP);
				pvPut(Cam4MotorSTUP);
				pvPut(Cam5MotorSTUP);
			}
			if(transMotorMoving==0) {
				pvPut(Trans1MotorSTUP);
				pvPut(Trans2MotorSTUP);
			}
		} state waitForIssue

		when (Cam1MotorSTAT != Cam1prevAlarmState) {

		} state Cam1CommChange
		
		when (Cam2MotorSTAT != Cam2prevAlarmState) {

		} state Cam2CommChange
		
		when (Cam3MotorSTAT != Cam3prevAlarmState) {
		} state Cam3CommChange
		
		when (Cam4MotorSTAT != Cam4prevAlarmState) {
		} state Cam4CommChange
		
		when (Cam5MotorSTAT != Cam5prevAlarmState) {
		} state Cam5CommChange
		
		when (Trans1MotorSTAT != Trans1prevAlarmState) {
		} state Trans1CommChange
		
		when (Trans2MotorSTAT != Trans2prevAlarmState) {
		} state Trans2CommChange
		
		when ((fabs(Cam1MotorRBV - Cam1Position) > allowableCamDiff) &&
				!Cam1posError) {
			Cam1posError = 1;

		} state Cam1PosChange

		when ((fabs(Cam2MotorRBV - Cam2Position) > allowableCamDiff) &&
				!Cam2posError) {
			Cam2posError = 1;

		} state Cam2PosChange

		when ((fabs(Cam3MotorRBV - Cam3Position) > allowableCamDiff) &&
				!Cam3posError) {
			Cam3posError = 1;
		} state Cam3PosChange

		when ((fabs(Cam4MotorRBV - Cam4Position) > allowableCamDiff) &&
				!Cam4posError) {
			Cam4posError = 1;
		} state Cam4PosChange

		when ((fabs(Cam5MotorRBV - Cam5Position) > allowableCamDiff) &&
				!Cam5posError) {
			Cam5posError = 1;
		} state Cam5PosChange

		when ((fabs(Trans1MotorRBV - Trans1Position) > allowableTransDiff) &&
				!Trans1posError) {
			Trans1posError = 1;
		} state Trans1PosChange

		when ((fabs(Trans2MotorRBV - Trans2Position) > allowableTransDiff) &&
				!Trans2posError) {
			Trans2posError = 1;
		} state Trans2PosChange

		when ((fabs(Cam1MotorRBV - Cam1Position) < allowableCamDiff) &&
				Cam1posError) {
			Cam1posError = 0;

		} state Cam1PosChange

		when ((fabs(Cam2MotorRBV - Cam2Position) < allowableCamDiff) &&
				Cam2posError) {
			Cam2posError = 0;

		} state Cam2PosChange

		when ((fabs(Cam3MotorRBV - Cam3Position) < allowableCamDiff) &&
				Cam3posError) {
			Cam3posError = 0;
		} state Cam3PosChange

		when ((fabs(Cam4MotorRBV - Cam4Position) < allowableCamDiff) &&
				Cam4posError) {
			Cam4posError = 0;
		} state Cam4PosChange

		when ((fabs(Cam5MotorRBV - Cam5Position) < allowableCamDiff) &&
				Cam5posError) {
			Cam5posError = 0;
		} state Cam5PosChange

		when ((fabs(Trans1MotorRBV - Trans1Position) < allowableTransDiff) &&
				Trans1posError) {
			Trans1posError = 0;
		} state Trans1PosChange

		when ((fabs(Trans2MotorRBV - Trans2Position) < allowableTransDiff) &&
				Trans2posError) {
			Trans2posError = 0;
		} state Trans2PosChange

		when (Cam1motionOverride && !Cam1motionOverridden) {
			Cam1motorStatus = 3;
			pvPut(Cam1motorStatus);
			Cam1motionOverridden = 1;
		} state waitForIssue

		when (Cam2motionOverride && !Cam2motionOverridden) {
			Cam2motorStatus = 3;
			pvPut(Cam2motorStatus);
			Cam2motionOverridden = 1;
		} state waitForIssue

		when (Cam3motionOverride && !Cam3motionOverridden) {
			Cam3motorStatus = 3;
			pvPut(Cam3motorStatus);
			Cam3motionOverridden = 1;
		} state waitForIssue

		when (Cam4motionOverride && !Cam4motionOverridden) {
			Cam4motorStatus = 3;
			pvPut(Cam4motorStatus);
			Cam4motionOverridden = 1;
		} state waitForIssue

		when (Cam5motionOverride && !Cam5motionOverridden) {
			Cam5motorStatus = 3;
			pvPut(Cam5motorStatus);
			Cam5motionOverridden = 1;
		} state waitForIssue

		when (Trans1motionOverride && !Trans1motionOverridden) {
			Trans1motorStatus = 3;
			pvPut(Trans1motorStatus);
			Trans1motionOverridden = 1;
		} state waitForIssue

		when (Trans2motionOverride && !Trans2motionOverridden) {
			Trans2motorStatus = 3;
			pvPut(Trans2motorStatus);
			Trans2motionOverridden = 1;
		} state waitForIssue

		when (!Cam1motionOverride && Cam1motionOverridden) {
			Cam1motorStatus = 0;
			pvPut(Cam1motorStatus);
			Cam1motionOverridden = 0;
			Cam1prevAlarmState = -1;
		} state waitForIssue

		when (!Cam2motionOverride && Cam2motionOverridden) {
			Cam2motorStatus = 0;
			pvPut(Cam2motorStatus);
			Cam2motionOverridden = 0;
			Cam2prevAlarmState = -1;
		} state waitForIssue

		when (!Cam3motionOverride && Cam3motionOverridden) {
			Cam3motorStatus = 0;
			pvPut(Cam3motorStatus);
			Cam3motionOverridden = 0;
			Cam3prevAlarmState = -1;
		} state waitForIssue

		when (!Cam4motionOverride && Cam4motionOverridden) {
			Cam4motorStatus = 0;
			pvPut(Cam4motorStatus);
			Cam4motionOverridden = 0;
			Cam4prevAlarmState = -1;
		} state waitForIssue

		when (!Cam5motionOverride && Cam5motionOverridden) {
			Cam5motorStatus = 0;
			pvPut(Cam5motorStatus);
			Cam5motionOverridden = 0;
			Cam5prevAlarmState = -1;
		} state waitForIssue

		when (!Trans1motionOverride && Trans1motionOverridden) {
			Trans1motorStatus = 0;
			pvPut(Trans1motorStatus);
			Trans1motionOverridden = 0;
			Trans1prevAlarmState = -1;
		} state waitForIssue

		when (!Trans2motionOverride && Trans2motionOverridden) {
			Trans2motorStatus = 0;
			pvPut(Trans2motorStatus);
			Trans2motionOverridden = 0;
			Trans2prevAlarmState = -1;
		} state waitForIssue

		when (excitationSTAT != excitationPrevAlarmState) {
			
		} state excitationChange
	}

#define CHANGE(prefix) 																	\
	/************************/															\
	/*    position change   */															\
	/************************/															\
	state prefix##PosChange																\
	{																					\
		entry {																			\
																						\
		}																				\
																						\
		when(prefix##posError) {				/* motor and potentiometer disagree */	\
				prefix##prevAlarmState = 1;												\
				pvPut(prefix##posError);												\
		} state setAlarmStatus															\
																						\
		when(!prefix##posError) {				/* motor and potentiometer agree */		\
				prefix##prevAlarmState = 0;												\
				pvPut(prefix##posError);												\
		} state setAlarmStatus															\
	}																					\

CHANGE(Cam1)
CHANGE(Cam2)
CHANGE(Cam3)
CHANGE(Cam4)
CHANGE(Cam5)
CHANGE(Trans1)
CHANGE(Trans2)

#define COMM(prefix) 																	\
	/******************************/													\
	/*    communitcation change   */													\
	/******************************/													\
	state prefix##CommChange															\
	{																					\
		entry {																			\
																						\
		}																				\
																						\
		when(prefix##MotorSTAT != prefix##prevAlarmState) {								\
				prefix##prevAlarmState = prefix##MotorSTAT;								\
				prefix##comError = (prefix##MotorSTAT > 0) ? 1 : 0;						\
				pvPut(prefix##comError);												\
				efClear(prefix##MotorSTATev);											\
		} state setAlarmStatus															\
	}																					\

COMM(Cam1)
COMM(Cam2)
COMM(Cam3)
COMM(Cam4)
COMM(Cam5)
COMM(Trans1)
COMM(Trans2)

	/**********************************/
	/*    excitation voltage change   */
	/**********************************/
	state excitationChange
	{
		entry {

		}

		when(excitationSTAT == 1) {
			excitationPrevAlarmState = excitationSTAT;
		} state waitForIssue

		when(excitationSTAT == 0) {
			excitationPrevAlarmState = excitationSTAT;
		} state waitForIssue
	}

	/************************/
	/*   set alarm status   */
	/************************/
	state setAlarmStatus
	{
		entry {

		}

		/**************************************************************/
		/* status values:	0 = Normal								  */
		/*					1 = Comm Error							  */
		/*					2 = Position Error						  */
		/*					3 = Override							  */
		/**************************************************************/
		when(1) {
			if(!Cam1comError && !Cam1posError) {
				Cam1motorStatus = 0;
				pvPut(Cam1motorStatus);
				if(Cam1motionOverridden) {
					Cam1motionOverridden = 0;
					Cam1motionOverride = 0;
					pvPut(Cam1motionOverride);
				}
			}

			if(!Cam2comError && !Cam2posError) {
				Cam2motorStatus = 0;
				pvPut(Cam2motorStatus);
				if(Cam2motionOverridden) {
					Cam2motionOverridden = 0;
					Cam2motionOverride = 0;
					pvPut(Cam2motionOverride);
				}
			}

			if(!Cam3comError && !Cam3posError) {
				Cam3motorStatus = 0;
				pvPut(Cam3motorStatus);
				if(Cam3motionOverridden) {
					Cam3motionOverridden = 0;
					Cam3motionOverride = 0;
					pvPut(Cam3motionOverride);
				}
			}

			if(!Cam4comError && !Cam4posError) {
				Cam4motorStatus = 0;
				pvPut(Cam4motorStatus);
				if(Cam4motionOverridden) {
					Cam4motionOverridden = 0;
					Cam4motionOverride = 0;
					pvPut(Cam4motionOverride);
				}
			}

			if(!Cam5comError && !Cam5posError) {
				Cam5motorStatus = 0;
				pvPut(Cam5motorStatus);
				if(Cam5motionOverridden) {
					Cam5motionOverridden = 0;
					Cam5motionOverride = 0;
					pvPut(Cam5motionOverride);
				}
			}

			if(!Trans1comError && !Trans1posError) {
				Trans1motorStatus = 0;
				pvPut(Trans1motorStatus);
				if(Trans1motionOverridden) {
					Trans1motionOverridden = 0;
					Trans1motionOverride = 0;
					pvPut(Trans1motionOverride);
				}
			}

			if(!Trans2comError && !Trans2posError) {
				Trans2motorStatus = 0;
				pvPut(Trans2motorStatus);
				if(Trans2motionOverridden) {
					Trans2motionOverridden = 0;
					Trans2motionOverride = 0;
					pvPut(Trans2motionOverride);
				}
			}

			if(Cam1posError) {
				stopCamMotors = 1;
				pvPut(stopCamMotors);
				Cam1motorStatus = 2;
				pvPut(Cam1motorStatus);
			}

			if(Cam2posError) {
				stopCamMotors = 1;
				pvPut(stopCamMotors);
				Cam2motorStatus = 2;
				pvPut(Cam2motorStatus);
			}

			if(Cam3posError) {
				stopCamMotors = 1;
				pvPut(stopCamMotors);
				Cam3motorStatus = 2;
				pvPut(Cam3motorStatus);
			}

			if(Cam4posError) {
				stopCamMotors = 1;
				pvPut(stopCamMotors);
				Cam4motorStatus = 2;
				pvPut(Cam4motorStatus);
			}

			if(Cam5posError) {
				stopCamMotors = 1;
				pvPut(stopCamMotors);
				Cam5motorStatus = 2;
				pvPut(Cam5motorStatus);
			}

			if(Cam1comError) {
				stopCamMotors = 1;
				pvPut(stopCamMotors);
				Cam1motorStatus = 1;
				pvPut(Cam1motorStatus);
			}

			if(Cam2comError) {
				stopCamMotors = 1;
				pvPut(stopCamMotors);
				Cam2motorStatus = 1;
				pvPut(Cam2motorStatus);
			}

			if(Cam3comError) {
				stopCamMotors = 1;
				pvPut(stopCamMotors);
				Cam3motorStatus = 1;
				pvPut(Cam3motorStatus);
			}

			if(Cam4comError) {
				stopCamMotors = 1;
				pvPut(stopCamMotors);
				Cam4motorStatus = 1;
				pvPut(Cam4motorStatus);
			}

			if(Cam5comError) {
				stopCamMotors = 1;
				pvPut(stopCamMotors);
				Cam5motorStatus = 1;
				pvPut(Cam5motorStatus);
			}

			if(Trans1posError) {
				stopTransMotors = 1;
				pvPut(stopTransMotors);

				Trans1motorStatus = 2;
				pvPut(Trans1motorStatus);

                                Trans1MotorSPMG = 0;
                                pvPut(Trans1MotorSPMG);

                                Trans2MotorSPMG = 0;
                                pvPut(Trans2MotorSPMG);
			}

			if(Trans2posError) {
				stopTransMotors = 1;
				pvPut(stopTransMotors);

				Trans2motorStatus = 2;
				pvPut(Trans2motorStatus);

                                Trans1MotorSPMG = 0;
                                pvPut(Trans1MotorSPMG);

                                Trans2MotorSPMG = 0;
                                pvPut(Trans2MotorSPMG);
			}

			if(Trans1comError) {
				stopTransMotors = 1;
				pvPut(stopTransMotors);
				Trans1motorStatus = 1;
				pvPut(Trans1motorStatus);
                                Trans1MotorSPMG = 0;
                                pvPut(Trans1MotorSPMG);
                                Trans2MotorSPMG = 0;
                                pvPut(Trans2MotorSPMG);
			}

			if(Trans2comError) {
				stopTransMotors = 1;
				pvPut(stopTransMotors);
				Trans2motorStatus = 1;
				pvPut(Trans2motorStatus);
                                Trans2MotorSPMG = 0;
                                pvPut(Trans2MotorSPMG);
                                Trans1MotorSPMG = 0;
                                pvPut(Trans1MotorSPMG);
			}
		} state waitForIssue
	}

	/*******************************/
	/*   motion control override   */
	/*******************************/
	state motionCtlOverride
	{
		when(1) {

		} state waitForIssue
	}

	/*****************************/
	/*   ignore smart monitors   */
	/*****************************/
	state ignoreSmartMonitors
	{
		entry {
			efClear(Cam1MotorSTATev);
			efClear(Cam2MotorSTATev);
			efClear(Cam3MotorSTATev);
			efClear(Cam4MotorSTATev);
			efClear(Cam5MotorSTATev);
			efClear(Trans1MotorSTATev);
			efClear(Trans2MotorSTATev);
			Cam1posError = 0;
			Cam2posError = 0;
			Cam3posError = 0;
			Cam4posError = 0;
			Cam5posError = 0;
			Trans1posError = 0;
			Trans2posError = 0;
			pvPut(Cam1posError);
			pvPut(Cam2posError);
			pvPut(Cam3posError);
			pvPut(Cam4posError);
			pvPut(Cam5posError);
			pvPut(Trans1posError);
			pvPut(Trans2posError);
			Cam1comError = 0;
			Cam2comError = 0;
			Cam3comError = 0;
			Cam4comError = 0;
			Cam5comError = 0;
			Trans1comError = 0;
			Trans2comError = 0;
			pvPut(Cam1comError);
			pvPut(Cam2comError);
			pvPut(Cam3comError);
			pvPut(Cam4comError);
			pvPut(Cam5comError);
			pvPut(Trans1comError);
			pvPut(Trans2comError);
			Cam1motorStatus = 0;
			Cam2motorStatus = 0;
			Cam3motorStatus = 0;
			Cam4motorStatus = 0;
			Cam5motorStatus = 0;
			Trans1motorStatus = 0;
			Trans2motorStatus = 0;
			pvPut(Cam1motorStatus);
			pvPut(Cam2motorStatus);
			pvPut(Cam3motorStatus);
			pvPut(Cam4motorStatus);
			pvPut(Cam5motorStatus);
			pvPut(Trans1motorStatus);
			pvPut(Trans2motorStatus);
			Cam1prevAlarmState = -1;
			Cam2prevAlarmState = -1;
			Cam3prevAlarmState = -1;
			Cam4prevAlarmState = -1;
			Cam5prevAlarmState = -1;
			Trans1prevAlarmState = -1;
			Trans2prevAlarmState = -1;
			excitationPrevAlarmState = -1;
		}

		when(smartMonitorCtl) {
			smartMonitorStatus = 1;				/* turn smart monitor status "On" */
			pvPut(smartMonitorStatus);
		} state waitForIssue
	}
}
