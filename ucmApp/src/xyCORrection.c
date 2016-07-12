/* subroutine record for calculating X and Y cor offset due to undulator position */
/*										 */
/*								         	*/
/* Version History:								*/
/*	07/01/2010	alarcon		initial version			  	*/


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

#define	MMFL	6;
#define MULT 100000;
#define DEN  74;

long	calcXYCorInit(struct genSubRecord *pgsub)
{
	return(0);
}

long	calcI1(struct genSubRecord *pgsub)
{
	double	xact		 = *(double *)pgsub->a;
        double	i1bbmmfl	 = *(double *)pgsub->b;
	double	xoutcor1       	 = *(double *)pgsub->c;
	double	xoutcor2         = *(double *)pgsub->d;
        double  plane            = *(double *)pgsub->e;
        double  i1bbxact         = *(double *)pgsub->f;

        double i1 = 0;
	double mmflimit =  MMFL;
        double multiplier = MULT;
        double denominator = DEN;
        
	// if undulator within mmflimit, then unse i1bb, otherwise interpolate
        if ( xact <= mmflimit )
	  i1 = i1bbxact;  
	else if ( xact > mmflimit  )
       	  i1 = i1bbmmfl + (( xact - mmflimit ) / denominator ) * ( ( plane * multiplier ) * ( xoutcor1 + xoutcor2 ) - i1bbmmfl );
	else
	  i1 = 0;

	*(double *)pgsub->vala = i1;

return(0);
}

long	calcI2(struct genSubRecord *pgsub)
{
	double	xact		 = *(double *)pgsub->a;
	double	xoutcor1       	 = *(double *)pgsub->c;
        double  plane            = *(double *)pgsub->e;
        double	i2mmfl		 = *(double *)pgsub->g;
        double  i2xact           = *(double *)pgsub->h;
        double  r                = *(double *)pgsub->i;

        double i2 = 0;
	double mmflimit =  MMFL;
        double multiplier = MULT;
        double denominator = DEN;

	// if undulator within mmflimit, then unse i2xact, otherwise interpolate
        if ( xact <= mmflimit )
	  i2 = i2xact;  
	else if ( xact > mmflimit )
	  i2 = i2mmfl + (( xact - mmflimit ) / denominator ) * ( r*plane*xoutcor1*multiplier - i2mmfl );
	else
          i2 = 0;

	*(double *)pgsub->valb = i2;


return(0);
}

long	calcDELTAI(struct genSubRecord *pgsub)
{

        double  plane            = *(double *)pgsub->e;
        double  r                = *(double *)pgsub->i;
        double  polyb            = *(double *)pgsub->j;
        double  rn1              = *(double *)pgsub->k;
        double  i1txc            = *(double *)pgsub->l;
        double  i2txc            = *(double *)pgsub->m;
        double  i2txcn1          = *(double *)pgsub->n;

	double deltai = 0;
        double multiplier = MULT;
	  
        if (rn1 > 0)
          deltai = (0.00001*plane*polyb)*(i1txc - (i2txc/r) + (i2txcn1/rn1));
	else
          deltai = (0.00001*plane*polyb)*(i1txc - (i2txc/r));

	*(double *)pgsub->valc = deltai;

return(0);
}

epicsRegisterFunction(calcXYCorInit);
epicsRegisterFunction(calcI1);
epicsRegisterFunction(calcI2);
epicsRegisterFunction(calcDELTAI);
