/* subroutine record for calculating the girder roll					*/
/*																		*/
/*																		*/
/* Version History:														*/
/*	04/03/2008	ses		initial version									*/
/*																		*/

#include <epicsStdlib.h>
#include <epicsStdioRedirect.h>
#include <epicsMath.h>
#include <dbAccess.h>
#include <dbEvent.h>
#include <dbDefs.h>
#include <recGbl.h>
#include <dbCommon.h>
#include <registryFunction.h>
#include <epicsExport.h>
#include <recSup.h>
#include <genSubRecord.h>
#include <pinfo.h>

/* r1     = radius of CAM1												*/
/* r2     = radius of CAM2												*/
/* r3     = radius of CAM3												*/
/* X1     = distance between beam center and CAM1						*/
/* X23    = 															*/
/* beta2  = angle of CAM2 wedge block in radians						*/
/* beta3  = angle of CAM3 wedge block in radians						*/
/* phi1 = position based on rotary potentiometer readback for CAM1	*/
/* phi2 = position based on rotary potentiometer readback for CAM2	*/
/* phi3 = position based on rotary potentiometer readback for CAM3	*/

/* gammaRoll  = amount of roll in the system 								*/

long	rollCalcInit(struct	genSubRecord *pgsub)
{
	return(0);
}

long	rollCalc(struct	genSubRecord *pgsub)
{
	double	r1		= *(double *)pgsub->a;
	double	r2		= *(double *)pgsub->b;
	double	r3		= *(double *)pgsub->c;
	double	X1		= *(double *)pgsub->d;
	double	X23		= *(double *)pgsub->e;
	double	beta2	= *(double *)pgsub->f;
	double	beta3	= *(double *)pgsub->g;
	double	phi1	= *(double *)pgsub->h;
	double	phi2	= *(double *)pgsub->i;
	double	phi3	= *(double *)pgsub->j;

	double	gammaRoll = -((r1 * sin(phi1)) / (X1 + X23)) + 
			((r2 * sin(phi2) * sin(beta3)) + (r3 * sin(phi3) * sin(beta2))) /
			(sin(beta2 + beta3) * (X1 + X23));
	*(double *)pgsub->vala = gammaRoll;

return(0);
}

epicsRegisterFunction(rollCalcInit);
epicsRegisterFunction(rollCalc);