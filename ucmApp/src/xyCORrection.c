/* subroutine record for calculating X and Y cor offset due to undulator position */
/*                                                                                */
/*                                                                                */
/* Version History:                                                               */
/* 07/01/2010   alarcon     initial version                                       */


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

#define MMFL 6;
#define MULT 100000;
#define DEN  74;

long calcXYCorInit(struct aSubRecord *pasub)
{
    return(0);
}

long calcI1(struct aSubRecord *pasub)
{
    double xact     = *(double *)pasub->a;
    double i1bbmmfl = *(double *)pasub->b;
    double xoutcor1 = *(double *)pasub->c;
    double xoutcor2 = *(double *)pasub->d;
    double plane    = *(double *)pasub->e;
    double i1bbxact = *(double *)pasub->f;

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

    *(double *)pasub->vala = i1;

return(0);
}

long calcI2(struct aSubRecord *pasub)
{
    double xact     = *(double *)pasub->a;
    double xoutcor1 = *(double *)pasub->c;
    double  plane   = *(double *)pasub->e;
    double i2mmfl   = *(double *)pasub->g;
    double  i2xact  = *(double *)pasub->h;
    double  r       = *(double *)pasub->i;

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

    *(double *)pasub->valb = i2;

return(0);
}

long calcDELTAI(struct aSubRecord *pasub)
{

    double  plane   = *(double *)pasub->e;
    double  r       = *(double *)pasub->i;
    double  polyb   = *(double *)pasub->j;
    double  rn1     = *(double *)pasub->k;
    double  i1txc   = *(double *)pasub->l;
    double  i2txc   = *(double *)pasub->m;
    double  i2txcn1 = *(double *)pasub->n;

    double deltai = 0;
    double multiplier = MULT;
  
    if (rn1 > 0)
      deltai = (0.00001*plane*polyb)*(i1txc - (i2txc/r) + (i2txcn1/rn1));
    else
      deltai = (0.00001*plane*polyb)*(i1txc - (i2txc/r));

    *(double *)pasub->valc = deltai;

return(0);
}

epicsRegisterFunction(calcXYCorInit);
epicsRegisterFunction(calcI1);
epicsRegisterFunction(calcI2);
epicsRegisterFunction(calcDELTAI);
