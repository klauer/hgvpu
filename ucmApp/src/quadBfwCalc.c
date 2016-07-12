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
#include <genSubRecord.h>
#include <pinfo.h>

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
	LP		= *(double *)pgsub->a;
	ZP		= *(double *)pgsub->b;
	z_bfw	= *(double *)pgsub->c;
	QUADx	= *(double *)pgsub->d;
	QUADy	= *(double *)pgsub->e;
	BFWx	= *(double *)pgsub->f;
	BFWy	= *(double *)pgsub->g;
*/

long	calcQBInit(struct genSubRecord *pgsub)
{
	return(0);
}

long	calcQBPos(struct genSubRecord *pgsub)
{
	double	LP		= *(double *)pgsub->a;
	double	ZP		= *(double *)pgsub->b;
	double	z_bfw	= *(double *)pgsub->c;
	double	QUADx	= *(double *)pgsub->d;
	double	QUADy	= *(double *)pgsub->e;
	double	BFWx	= *(double *)pgsub->f;
	double	BFWy	= *(double *)pgsub->g;

	double	Xus = (QUADx - BFWx) * (z_bfw / (ZP + LP + z_bfw)) + BFWx;
	double	Yus = (QUADy - BFWy) * (z_bfw / (ZP + LP + z_bfw)) + BFWy;
	double	Xds = (QUADx - BFWx) * ((LP + z_bfw) / (ZP + LP + z_bfw)) + BFWx;
	double	Yds = (QUADy - BFWy) * ((LP + z_bfw) / (ZP + LP + z_bfw)) + BFWy;
	*(double *)pgsub->vala = Xus;
	*(double *)pgsub->valb = Yus;
	*(double *)pgsub->valc = Xds;
	*(double *)pgsub->vald = Yds;

return(0);
}

epicsRegisterFunction(calcQBInit);
epicsRegisterFunction(calcQBPos);