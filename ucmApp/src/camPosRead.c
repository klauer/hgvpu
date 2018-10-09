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
	gammaRoll	= *(double *)pasub->m;
	phi1	= *(double *)pasub->n;
	phi2	= *(double *)pasub->o;
	phi3	= *(double *)pasub->p;
	phi4	= *(double *)pasub->q;
	phi5	= *(double *)pasub->r;
*/

long	calcXyInit(struct aSubRecord *pasub)
{
	return(0);
}

long	calcXus(struct aSubRecord *pasub)
{
	double	r1		= *(double *)pasub->a;
	double	r2		= *(double *)pasub->b;
	double	r3		= *(double *)pasub->c;
	double	beta2	= *(double *)pasub->i;
	double	beta3	= *(double *)pasub->j;
	double	phi2	= *(double *)pasub->o;
	double	phi3	= *(double *)pasub->p;

	double	Xus = ((r2 * sin(phi2) * cos(beta3)) - (r3 * sin(phi3) * cos(beta2))) /
				  sin(beta2 + beta3);
	*(double *)pasub->vala = Xus;
	return(0);
}

long	calcYus(struct aSubRecord *pasub)
{
	double	r1		= *(double *)pasub->a;
	double	r2		= *(double *)pasub->b;
	double	r3		= *(double *)pasub->c;
	double	X1		= *(double *)pasub->f;
	double	X23		= *(double *)pasub->g;
	double	beta1	= *(double *)pasub->h;
	double	beta2	= *(double *)pasub->i;
	double	beta3	= *(double *)pasub->j;
	double	phi1	= *(double *)pasub->n;
	double	phi2	= *(double *)pasub->o;
	double	phi3	= *(double *)pasub->p;

	double	Yus = ((r1 * sin(phi1) * X23) / (X1 + X23)) +
				  (((r2 * sin(phi2) * sin(beta3)) + (r3 *sin(phi3) * sin(beta2))) / sin(beta2 + beta3)) *
				  (X1 / (X1 + X23));
	*(double *)pasub->valb = Yus;
	return(0);
}

long	calcXds(struct aSubRecord *pasub)
{
	double	r4		= *(double *)pasub->d;
	double	r5		= *(double *)pasub->e;
	double	beta4	= *(double *)pasub->k;
	double	beta5	= *(double *)pasub->l;
	double	phi4	= *(double *)pasub->q;
	double	phi5	= *(double *)pasub->r;

	double	Xds = ((r4 * sin(phi4) * cos(beta5)) - (r5 * sin(phi5) * cos(beta4))) /
				  sin(beta4 + beta5);
	*(double *)pasub->valc = Xds;
	return(0);
}

long	calcYds(struct aSubRecord *pasub)
{
	double	r4		= *(double *)pasub->d;
	double	r5		= *(double *)pasub->e;
	double	beta4	= *(double *)pasub->k;
	double	beta5	= *(double *)pasub->l;
	double	phi4	= *(double *)pasub->q;
	double	phi5	= *(double *)pasub->r;

	double	Yds = ((r4 * sin(phi4) * sin(beta5)) + (r5 * sin(phi5) * sin(beta4))) /
				  sin(beta4 + beta5);
	*(double *)pasub->vald = Yds;
	return(0);
}

epicsRegisterFunction(calcXyInit);
epicsRegisterFunction(calcXus);
epicsRegisterFunction(calcYus);
epicsRegisterFunction(calcXds);
epicsRegisterFunction(calcYds);
