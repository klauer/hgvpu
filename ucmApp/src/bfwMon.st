program bfwMon ("S={S}")

/*
 * 03/17/08 ses original code - monitor BFW issues
 */

option -c;       /* don't wait for all channels to connect */
/* option +r; */

%%#include	<epicsThread.h>
%%#include <epicsMath.h>

short	bfwStatus;
assign	bfwStatus to "{B}:STATUSM.VAL";

float	bfwPosition;
assign	bfwPosition to "{S}:LP9POSCALC";
monitor bfwPosition;

short	bfwPosC;
assign	bfwPosC to "{B}:ACTC";
monitor	bfwPosC;

float	bfwInPos;
assign	bfwInPos to "{B}:INPOS";
monitor	bfwInPos;

float	bfwOutPos;
assign	bfwOutPos to "{B}:OUTPOS";
monitor	bfwOutPos;

int32_t excitationSTAT;
assign	excitationSTAT to "{S}:EXCTTNADCM.STAT";
monitor	excitationSTAT;

/* This variable monitors if the smart monitors are enabled/disabled */
short	smartMonitorCtl;
assign	smartMonitorCtl to "{S}:SMRTMONITORC";
monitor	smartMonitorCtl;

/* This variable is the maximum allowable position differences */
float	allowableBfwDiff;
assign	allowableBfwDiff to "{B}:POSTOLERANCE";
monitor	allowableBfwDiff;

short	bfwPrevPos;


ss bfwMon
{
	state init
	{
		entry {
			bfwPrevPos = -1;
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

		when (!bfwPosC && (bfwPrevPos != 0)) {

		} state bfwMvOut

		when (bfwPosC && (bfwPrevPos == 0)) {

		} state bfwMvIn

		when (!smartMonitorCtl) {

		} state ignoreSmartMonitors
	}

	/********************/
	/*   bfw moving in  */
	/********************/
	state bfwMvIn
	{
		entry {
			bfwPrevPos = 1;
		}

		when(delay(5)) {
			if (fabs(bfwInPos - bfwPosition) > allowableBfwDiff) {
				bfwStatus = 0;
			}

			if (fabs(bfwInPos - bfwPosition) < allowableBfwDiff) {
				bfwStatus = 1;
			}
			pvPut(bfwStatus);
		} state waitForIssue
	}

	/*********************/
	/*   bfw moving out  */
	/*********************/
	state bfwMvOut
	{
		entry {
			bfwPrevPos = 0;
		}

		when(delay(5)) {
			if (fabs(bfwOutPos - bfwPosition) > allowableBfwDiff) {
				bfwStatus = 0;
			}

			if (fabs(bfwOutPos - bfwPosition) < allowableBfwDiff) {
				bfwStatus = 2;
			}
			pvPut(bfwStatus);
		} state waitForIssue
	}

	/*****************************/
	/*   ignore smart monitors   */
	/*****************************/
	state ignoreSmartMonitors
	{
		entry {
			bfwStatus = 1;
			pvPut(bfwStatus);
			bfwPrevPos = -1;
		}

		when(smartMonitorCtl) {

		} state waitForIssue
	}
}
