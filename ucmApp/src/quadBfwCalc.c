/* subroutine record for calculating motion about the Quad or BFW center	*/
/*																			*/
/*																			*/
/* Version History:															*/
/*	05/01/2008	ses		initial version										*/
/*																			*/

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

/* LP     = distance between support pedistals							*/
/* ZP     = distance between downstream support pedestal and Quad ctr	*/
/* z_bfw  = distance between upstream support pedestal and BFW ctr		*/
/* QUADx  = X set point for the ctr of the Quad with respect to BFW ctr	*/
/* QUADy  = Y set point for the ctr of the Quad with respect to BFW ctr	*/
/* BFWx   = X set point for the ctr of the BFW with respect to Quad ctr	*/
/* BFWy   = Y set point for the ctr of the BFW with respect to Quad ctr	*/

/* VALA   = Xus    = setpoint for X on the Upstream CAMS				*/
/* VALB   = Yus    = setpoint for Y on the Upstream CAMS				*/
/* VALC   = Xds    = setpoint for X on the Downstream CAMS				*/
/* VALD   = Yds    = setpoint for Y on the Downstream CAMS				*/

/*
	LP		= *(double *)pasub->a;
	ZP		= *(double *)pasub->b;
	z_bfw	= *(double *)pasub->c;
	QUADx	= *(double *)pasub->d;
	QUADy	= *(double *)pasub->e;
	BFWx	= *(double *)pasub->f;
	BFWy	= *(double *)pasub->g;
*/

long	calcQBInit(struct aSubRecord *pasub)
{
	return(0);
}

long	calcQBPos(struct aSubRecord *pasub)
{
	double	LP		= *(double *)pasub->a;
	double	ZP		= *(double *)pasub->b;
	double	z_bfw	= *(double *)pasub->c;
	double	QUADx	= *(double *)pasub->d;
	double	QUADy	= *(double *)pasub->e;
	double	BFWx	= *(double *)pasub->f;
	double	BFWy	= *(double *)pasub->g;

	double	Xus = (QUADx - BFWx) * (z_bfw / (ZP + LP + z_bfw)) + BFWx;
	double	Yus = (QUADy - BFWy) * (z_bfw / (ZP + LP + z_bfw)) + BFWy;
	double	Xds = (QUADx - BFWx) * ((LP + z_bfw) / (ZP + LP + z_bfw)) + BFWx;
	double	Yds = (QUADy - BFWy) * ((LP + z_bfw) / (ZP + LP + z_bfw)) + BFWy;
	*(double *)pasub->vala = Xus;
	*(double *)pasub->valb = Yus;
	*(double *)pasub->valc = Xds;
	*(double *)pasub->vald = Yds;

return(0);
}

epicsRegisterFunction(calcQBInit);
epicsRegisterFunction(calcQBPos);
