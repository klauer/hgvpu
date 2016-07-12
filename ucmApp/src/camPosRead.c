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
#include <genSubRecord.h>
#include <pinfo.h>

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
/* phi1 = position based on rotary potentiometer readback for CAM1	*/
/* phi2 = position based on rotary potentiometer readback for CAM2	*/
/* phi3 = position based on rotary potentiometer readback for CAM3	*/
/* phi4 = position based on rotary potentiometer readback for CAM4	*/
/* phi5 = position based on rotary potentiometer readback for CAM5	*/
/* gammaRoll  = amount of roll in the system 								*/

/* VALA   = Xus = setpoint for X on the Upstream CAMS					*/
/* VALB   = Yus = setpoint for Y on the Upstream CAMS					*/
/* VALC   = Xds = setpoint for X on the Downstream CAMS					*/
/* VALD   = Yds = setpoint for Y on the Downstream CAMS					*/

/*
	r1		= *(double *)pgsub->a;
	r2		= *(double *)pgsub->b;
	r3		= *(double *)pgsub->c;
	r4		= *(double *)pgsub->d;
	r5		= *(double *)pgsub->e;
	X1		= *(double *)pgsub->f;
	X23		= *(double *)pgsub->g;
	beta1	= *(double *)pgsub->h;
	beta2	= *(double *)pgsub->i;
	beta3	= *(double *)pgsub->j;
	beta4	= *(double *)pgsub->k;
	beta5	= *(double *)pgsub->l;
	gammaRoll	= *(double *)pgsub->m;
	phi1	= *(double *)pgsub->n;
	phi2	= *(double *)pgsub->o;
	phi3	= *(double *)pgsub->p;
	phi4	= *(double *)pgsub->q;
	phi5	= *(double *)pgsub->r;
*/

long	calcXyInit(struct genSubRecord *pgsub)
{
	return(0);
}

long	calcXus(struct genSubRecord *pgsub)
{
	double	r1		= *(double *)pgsub->a;
	double	r2		= *(double *)pgsub->b;
	double	r3		= *(double *)pgsub->c;
	double	beta2	= *(double *)pgsub->i;
	double	beta3	= *(double *)pgsub->j;
	double	phi2	= *(double *)pgsub->o;
	double	phi3	= *(double *)pgsub->p;

	double	Xus = ((r2 * sin(phi2) * cos(beta3)) - (r3 * sin(phi3) * cos(beta2))) /
				  sin(beta2 + beta3);
	*(double *)pgsub->vala = Xus;
	return(0);
}

long	calcYus(struct genSubRecord *pgsub)
{
	double	r1		= *(double *)pgsub->a;
	double	r2		= *(double *)pgsub->b;
	double	r3		= *(double *)pgsub->c;
	double	X1		= *(double *)pgsub->f;
	double	X23		= *(double *)pgsub->g;
	double	beta1	= *(double *)pgsub->h;
	double	beta2	= *(double *)pgsub->i;
	double	beta3	= *(double *)pgsub->j;
	double	phi1	= *(double *)pgsub->n;
	double	phi2	= *(double *)pgsub->o;
	double	phi3	= *(double *)pgsub->p;

	double	Yus = ((r1 * sin(phi1) * X23) / (X1 + X23)) +
				  (((r2 * sin(phi2) * sin(beta3)) + (r3 *sin(phi3) * sin(beta2))) / sin(beta2 + beta3)) *
				  (X1 / (X1 + X23));
	*(double *)pgsub->valb = Yus;
	return(0);
}

long	calcXds(struct genSubRecord *pgsub)
{
	double	r4		= *(double *)pgsub->d;
	double	r5		= *(double *)pgsub->e;
	double	beta4	= *(double *)pgsub->k;
	double	beta5	= *(double *)pgsub->l;
	double	phi4	= *(double *)pgsub->q;
	double	phi5	= *(double *)pgsub->r;

	double	Xds = ((r4 * sin(phi4) * cos(beta5)) - (r5 * sin(phi5) * cos(beta4))) /
				  sin(beta4 + beta5);
	*(double *)pgsub->valc = Xds;
	return(0);
}

long	calcYds(struct genSubRecord *pgsub)
{
	double	r4		= *(double *)pgsub->d;
	double	r5		= *(double *)pgsub->e;
	double	beta4	= *(double *)pgsub->k;
	double	beta5	= *(double *)pgsub->l;
	double	phi4	= *(double *)pgsub->q;
	double	phi5	= *(double *)pgsub->r;

	double	Yds = ((r4 * sin(phi4) * sin(beta5)) + (r5 * sin(phi5) * sin(beta4))) /
				  sin(beta4 + beta5);
	*(double *)pgsub->vald = Yds;
	return(0);
}

epicsRegisterFunction(calcXyInit);
epicsRegisterFunction(calcXus);
epicsRegisterFunction(calcYus);
epicsRegisterFunction(calcXds);
epicsRegisterFunction(calcYds);