/* subroutine record for calculating the upstream/downstream CAM motion */
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
#include <aSubRecord.h>
/*
#include <pinfo.h>
*/

/* r1     = radius of CAM1												*/
/* r2     = radius of CAM2												*/
/* r3     = radius of CAM3												*/
/* r4     = radius of CAM4												*/
/* r5     = radius of CAM5												*/
/* X1     = distance between beam center and CAM1						*/
/* X23    = 															*/
/* beta1  = angle of CAM1 wedge block in radians						*/
/* beta2  = angle of CAM2 wedge block in radians						*/
/* beta3  = angle of CAM3 wedge block in radians						*/
/* beta4  = angle of CAM4 wedge block in radians						*/
/* beta5  = angle of CAM5 wedge block in radians						*/
/* Xus    = setpoint for X on the Upstream CAMS							*/
/* Yus    = setpoint for Y on the Upstream CAMS							*/
/* Xds    = setpoint for X on the Downstream CAMS						*/
/* Yds    = setpoint for Y on the Downstream CAMS						*/
/* gammaRoll  = amount of roll in the system 								*/

/* VALA   = phi1 = calculated new position for moving CAM1				*/
/* VALB   = phi2 = calculated new position for moving CAM2				*/
/* VALC   = phi3 = calculated new position for moving CAM3				*/
/* VALD   = phi4 = calculated new position for moving CAM4				*/
/* VALE   = phi5 = calculated new position for moving CAM5				*/

/*
	r1		= *(double *)pasub->a;
	r2		= *(double *)pasub->b;
	r3		= *(double *)pasub->c;
	r4		= *(double *)pasub->d;
	r5		= *(double *)pasub->e;
	X1		= *(double *)pasub->f;
	X23		= *(double *)pasub->g;
	beta1	= *(double *)pasub->h;
	beta2	= *(double *)pasub->i;
	beta3	= *(double *)pasub->j;
	beta4	= *(double *)pasub->k;
	beta5	= *(double *)pasub->l;
	Xus		= *(double *)pasub->m;
	Yus		= *(double *)pasub->n;
	Xds		= *(double *)pasub->o;
	Yds		= *(double *)pasub->p;
	gammaRoll	= *(double *)pasub->q;
*/
#define	CONV	57.29577951308232087721;

long	calcCMxInit(struct aSubRecord *pasub)
{
	return(0);
}

long	calcCM1(struct aSubRecord *pasub)
{
	double	r1		= *(double *)pasub->a;
	double	X1		= *(double *)pasub->f;
	double	Yus		= *(double *)pasub->n;
	double	gammaRoll	= *(double *)pasub->q;
		
	double	phi1 = asin((Yus + gammaRoll * X1) / r1);
	phi1 = phi1 * CONV;
	*(double *)pasub->vala = phi1;

return(0);
}

long	calcCM2(struct aSubRecord *pasub)
{
	double	r2		= *(double *)pasub->b;
	double	X23		= *(double *)pasub->g;
	double	beta2	= *(double *)pasub->i;
	double	Xus		= *(double *)pasub->m;
	double	Yus		= *(double *)pasub->n;
	double	gammaRoll	= *(double *)pasub->q;
	
	double	phi2 = asin(((Yus - gammaRoll * X23) * cos(beta2) + (Xus * sin(beta2))) / r2);
	phi2 = phi2 * CONV;
	*(double *)pasub->valb = phi2;

return(0);
}

long	calcCM3(struct aSubRecord *pasub)
{
	double	r3		= *(double *)pasub->c;
	double	X23		= *(double *)pasub->g;
	double	beta3	= *(double *)pasub->j;
	double	Xus		= *(double *)pasub->m;
	double	Yus		= *(double *)pasub->n;
	double	gammaRoll	= *(double *)pasub->q;
	
	double	phi3 = asin(((Yus - gammaRoll * X23) * cos(beta3) - (Xus * sin(beta3))) / r3);
	phi3 = phi3 * CONV;
	*(double *)pasub->valc = phi3;

return(0);
}

long	calcCM4(struct aSubRecord *pasub)
{
	double	r4		= *(double *)pasub->d;
	double	beta4	= *(double *)pasub->k;
	double	Xds		= *(double *)pasub->o;
	double	Yds		= *(double *)pasub->p;
	
	double	phi4 = asin(((Yds * cos(beta4)) + (Xds * sin(beta4))) / r4);
	phi4 = phi4 * CONV;
	*(double *)pasub->vald = phi4;

return(0);
}

long	calcCM5(struct aSubRecord *pasub)
{
	double	r5		= *(double *)pasub->e;
	double	beta5   = *(double *)pasub->l;
	double	Xds		= *(double *)pasub->o;
	double	Yds		= *(double *)pasub->p;
	
	double	phi5 = asin(((Yds * cos(beta5)) - (Xds * sin(beta5))) / r5);
	phi5 = phi5 * CONV;
	*(double *)pasub->vale = phi5;

return(0);
}

epicsRegisterFunction(calcCMxInit);
epicsRegisterFunction(calcCM1);
epicsRegisterFunction(calcCM2);
epicsRegisterFunction(calcCM3);
epicsRegisterFunction(calcCM4);
epicsRegisterFunction(calcCM5);
