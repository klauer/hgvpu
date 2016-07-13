/* drvTip114.c
    Author: Marty Smith

    This is the driver for the TEWS TIP114 SSI Interface
    10 channel absolute encoder 

    Address map:
	0x00 - Control   channel 0
	0x02 - Data low  channel 0
	0x04 - Data High channel 0
	.
	.
	0x36 - Control   channel 9
	0x38 - Data low  channel 9
	0x3A - Data High channel 9
	
	0x3C - Data ready status   ( bits 0-9 for ch0 -ch9) (1 = ready)
	0x3E - Parity Error status ( bits 0-9 for ch0 -ch9) (1 = error)
	
	0x40 - Interrupt status reg. ( bits 0-9 for ch0 -ch9) (1= data ready)
	0x42 - Interrupt enable reg. ( bits 0-9 for ch0 -ch9) (1 = enabled)
	0x45 - Interrupt vector reg.  
	0x47 - Start Convert ch0-ch9
	
	Control Register Channel bits:
	    0 - 3  : Clock rate steps of 1us from 1-15. 0 is disabled
	    4	   : Encoder with parity 1 = detect
	    5	   : Control parity 1 = odd and 0 =even
	    6	   : Parity with Zero bit. 1= 2 add clk and 0= 1 add clk cycle.
	    7	   : Gray code 1 = Gray and 0 = binary
	    8 - 13 : Number of bits from 1 to 32 only.
		
	To initiate a read one has to write a value to the data low register
	then check the data ready bit OR
	if interrupts are enabled check the interrupt bit
	Finally read the data low and data high registers and 
	add then with shifting the high 16 bits.

*/

/* System includes */
#include <stdlib.h>
#include <string.h>

#include <string.h>
#include <stdio.h>

/* EPICS includes */
#include <drvIpac.h>
#include <devLib.h>
#include <errlog.h>
#include <cantProceed.h>
#include <epicsString.h>
#include <epicsTimer.h>
#include <epicsThread.h>
#include <epicsMessageQueue.h>
#include <epicsExit.h>
#include <asynDriver.h>
#include <asynInt32.h>
#include <asynDrvUser.h>
#include <iocsh.h>
#include <epicsExport.h>


#define TEWS 0xB3		/*  ID of the manufacturer  */
#define TIP114_NO 0x2A		/*  Model no of the TIP114 module  */

#define MAX_TIP114_CH 10

typedef struct tip114Chnl {
    epicsUInt16 controlRegister;     	/* Control  Register    */
    epicsUInt16 dataLow;         	/* Data low   Register  */
    epicsUInt16 dataHigh;     		/* Data High Register   */
} tip114Chnl;

typedef struct tip114Registers {
    tip114Chnl   channelRegister[MAX_TIP114_CH];  /* Channel contrl and data */
    epicsUInt16  dataReadyRegister;     /* Data ready status  */
    epicsUInt16  parityErrorRegister;   /* Parity Error status */
    epicsUInt16  intStatusRegister;   	/* Interrupt Status Register */
    epicsUInt16  intEnableRegister; 	/* Interrupt Enable Register */
    epicsUInt16  intVectorRegister;     /* Interrupt vector          */
    epicsUInt16  startCnvtRegister;     /* All ch Start Converion   */
} tip114Registers;


typedef struct drvTip114Pvt {
    char *portName;
    asynUser *pasynUser;
    ushort_t carrier;
    ushort_t slot;
    volatile tip114Registers *regs;
    int rebooting;
    double pollTime;
    asynInterface common;
    asynInterface int32;
} drvTip114Pvt;


/* These functions are used by the interfaces */
static void report                  (void *drvPvt, FILE *fp, int details);
static asynStatus connect           (void *drvPvt, asynUser *pasynUser);
static asynStatus disconnect        (void *drvPvt, asynUser *pasynUser);

static asynStatus readInt32         (void *drvPvt, asynUser *pasynUser,
                                     epicsInt32 *value);

/* These are private functions, not used in any interfaces */
static void pollerThread      (drvTip114Pvt *pPvt);
static void rebootCallback    (void *drvPvt);


static asynCommon drvTip114Common = {
    report,
    connect,
    disconnect
};

static asynInt32 drvTip114Int32 = {
    NULL,
    readInt32,
    NULL,
    NULL,
    NULL
};

/* Initialize the IP Module */
int initTip114 (const char *portName, ushort_t carrier, ushort_t slot, int intVec)
{
    ipac_idProm_t *id;
    unsigned char manufacturer;
    unsigned char model;
    drvTip114Pvt *pPvt;
    asynStatus status;
    
    printf("Entering TIP114 Init\n");
    pPvt = callocMustSucceed(1, sizeof(*pPvt), "initTip114");
    pPvt->portName = epicsStrDup(portName);
    pPvt->carrier = carrier;
    pPvt->slot = slot;
 
    if (ipmCheck(carrier, slot)) {
       errlogPrintf("initTip114: bad carrier or slot\n");
       return -1;
    }

    id = (ipac_idProm_t *) ipmBaseAddr(carrier, slot, ipac_addrID);
    manufacturer = id->manufacturerId & 0xff;
    model = id->modelId & 0xff;
    if(manufacturer != TEWS) {
        errlogPrintf("initTip114: TEWS manufacturer 0x%x not supported\n",
                     manufacturer);
        return(-1);
    }
    if(model != TIP114_NO) {
       errlogPrintf("initTip114 model 0x%x not a TIP114_NO\n",model);
       return(-1);
    }

    /* Link with higher level routines */
    pPvt->common.interfaceType = asynCommonType;
    pPvt->common.pinterface  = (void *)&drvTip114Common;
    pPvt->common.drvPvt = pPvt;
    pPvt->int32.interfaceType = asynInt32Type;
    pPvt->int32.pinterface  = (void *)&drvTip114Int32;
    pPvt->int32.drvPvt = pPvt;

    status = pasynManager->registerPort(portName,
                                        ASYN_MULTIDEVICE, /*is multiDevice*/
                                        1,  /*  autoconnect */
                                        0,  /* medium priority */
                                        0); /* default stack size */
    if (status != asynSuccess) {
        errlogPrintf("initTip114 ERROR: Can't register port\n");
        return(-1);
    }
    status = pasynManager->registerInterface(portName,&pPvt->common);
    if (status != asynSuccess) {
        errlogPrintf("initTip114 ERROR: Can't register common.\n");
        return(-1);
    }
    status = pasynInt32Base->initialize(pPvt->portName,&pPvt->int32);
    if (status != asynSuccess) {
        errlogPrintf("initTip114 ERROR: Can't register int32\n");
        return(-1);
    }

    /* Create asynUser for debugging asynTrace*/
    pPvt->pasynUser = pasynManager->createAsynUser(0, 0);

    /* Connect to device */
    status = pasynManager->connectDevice(pPvt->pasynUser, portName, 0);
    if (status != asynSuccess) {
        errlogPrintf("initTip114, connectDevice failed for tip114 on port %s\n", portName);
        return(-1);
    }

    /* Program device registers */
    pPvt->regs = (tip114Registers *) ipmBaseAddr(carrier, slot, ipac_addrIO);;

    epicsAtExit(rebootCallback, pPvt);
    return 0;
}

/*  Configure each channel with One call each for each channel 
	Any channel configured witha clk speed of 0 is disabled
	
 */
int configTip114 (const char *portName, int channel, int nbits, int clk, 
		  const char *gray, const char *parity, int zeroBits)
{
    asynStatus status;
    asynInterface *pasynInterface;
    asynUser *pasynUser;
    drvTip114Pvt *pPvt;
    epicsUInt16  word;	/* Control Register Word */
    
    pasynUser = pasynManager->createAsynUser(0, 0);
    status = pasynManager->connectDevice(pasynUser, portName, 0);
    if (status != asynSuccess) {
        errlogPrintf("configTip114, error in connectDevice %s\n",
                     pasynUser->errorMessage);
        return(-1);
    }
    pasynInterface = pasynManager->findInterface(pasynUser, asynInt32Type, 1);
    if (!pasynInterface) {
        errlogPrintf("configTip114: cannot find TIP114 Int32 interface %s\n",
                     pasynUser->errorMessage);
        return(-1);
    }
    pPvt = pasynInterface->drvPvt;

    if (channel < 0 || channel >= MAX_TIP114_CH) {
        errlogPrintf("configTip114: Invalid channel Number %d !\n",
                     channel);
        return(-1);
    }
/*
    WARNING: This driver blocks until the channel data is ready.
    	This could cause slow database processing if a slow clock is
	used with multiple channels.
*/
    if (clk < 1 || clk > 15) {
        errlogPrintf("configTip114: Invalid clock rate [%d] for channel %d\n",
                     clk, channel);
        return(-1);
    } else 
    	word = clk;

    if (nbits < 1 || nbits > 32) {
        errlogPrintf("configTip114: Invalid No of Bits [%d] for channel %d\n",
                     nbits, channel);
        return(-1);
    } else 
    	word |= nbits << 8;

/* If Gray Scale, otherwise Natural Binary*/
    if (epicsStrCaseCmp(gray,"G") == 0)	
    	word |= 1 << 7;

    	/* Zero Bits Clock cycle control */
    if (zeroBits == 1)	/* 1 = add 2 clock cycles */
        word |= 1 << 6;	/* 0 = add 1 clock cycle */
	
    if (epicsStrCaseCmp(parity,"O") == 0) {	/* Odd Parity */
        word |= 3 << 4;	
    } else if (epicsStrCaseCmp(parity,"E") == 0) {	/* Even Parity */
        word |= 1 << 4;	
    
    }    
    /*  based on channel configuration enter into channel control register */   
    pPvt->regs->channelRegister[channel].controlRegister = word;

    return(0);
}



static asynStatus readInt32(void *drvPvt, asynUser *pasynUser, 
                            epicsInt32 *value)
{
    drvTip114Pvt *pPvt = (drvTip114Pvt *)drvPvt;
    int channel;
    epicsUInt16 dlow;
    epicsUInt16 dhigh;
    int ntimes;
   
    if (pPvt->rebooting) epicsThreadSuspendSelf();
    /*  get the address from the INP field to reflect the channel number */
    pasynManager->getAddr(pasynUser, &channel);

    /* start the convertion by writing any value to data low ....*/
    pPvt->regs->channelRegister[channel].dataLow = 1;
	
   /* This is to force the previous write to the VME bus, otherwise
    * the conversion will not start when we read the dataReadyRegister
    * The code will however work if compiled un-optimized or at optimization
    * -O1 but not at -O2 even without this line of code.
    */
    dlow  =  pPvt->regs->channelRegister[channel].dataLow;

/*
    This will start conversion for all channels
    pPvt->regs->startCnvtRegister = 1;
*/
    
    /*  now check the ready register for the specific channels bit to be set */
    ntimes = 0;
    while ((pPvt->regs->dataReadyRegister & (1<<channel)) == 0) {
        if (++ntimes > 10000)
            return asynTimeout;
    }
/*
    ntimes = 0;
    while (ntimes++ < 10000) {	
        if ( pPvt->regs->dataReadyRegister & (1<<channel) ) break;
    }
    if( ntimes == 10000) {
        errlogPrintf("drvTip114 Channel %d Read timeout %d!\n", 
                     channel, ntimes);
    }
*/
    asynPrint(pasynUser, ASYN_TRACEIO_DRIVER,
              "drvTip114::readInt32, channel=%d read in cycles=%d\n", 
              	channel, ntimes);
/* Get the channel data */
    dlow  =  pPvt->regs->channelRegister[channel].dataLow;
    dhigh =  pPvt->regs->channelRegister[channel].dataHigh;

    *value = (epicsUInt32) dlow + (epicsUInt32) (dhigh << 16);

    asynPrint(pasynUser, ASYN_TRACEIO_DRIVER,
              "drvTip114::readInt32, channel=%d value=%d dataLow=%x  dataHigh=%x\n", 
              channel, *value,dlow,dhigh);

    return(asynSuccess);
}

static void rebootCallback(void *drvPvt)
{
    drvTip114Pvt *pPvt = (drvTip114Pvt *)drvPvt;
    pPvt->regs->intEnableRegister = 0;
    pPvt->rebooting = 1;
}


/* asynCommon routines */

/* Report  parameters */
static void report(void *drvPvt, FILE *fp, int details)
{
    drvTip114Pvt *pPvt = (drvTip114Pvt *)drvPvt;
    int i;

    fprintf(fp, "Port: %s, carrier %d slot %d, base address= %p\n", 
            pPvt->portName, pPvt->carrier, pPvt->slot, (void *)pPvt->regs);
    if (details >= 1) {
        fprintf(fp, "    intStatusRegister= 0x%x\n",
    	    	    pPvt->regs->intStatusRegister);
        fprintf(fp, "    intEnableRegister= 0x%x\n",
    	    	    pPvt->regs->intEnableRegister);
        fprintf(fp, "    intVectorRegister= 0x%x\n",
    	    	    pPvt->regs->intVectorRegister);
        fprintf(fp, "    ParityErrorRegister= 0x%x\n",
    	    	    pPvt->regs->parityErrorRegister);
        fprintf(fp, "    DataReadyRegister= 0x%x\n",
    	    	    pPvt->regs->dataReadyRegister);

        for (i=0; i<MAX_TIP114_CH; i++) {
    	    fprintf(fp, "    chan %d cntl = 0x%x  Data L = 0x%x Data H = 0x%x\n",
                   i, pPvt->regs->channelRegister[i].controlRegister,
    	    pPvt->regs->channelRegister[i].dataLow,
    	    pPvt->regs->channelRegister[i].dataHigh); 
        }
    }
}

/* Connect */
static asynStatus connect(void *drvPvt, asynUser *pasynUser)
{
    pasynManager->exceptionConnect(pasynUser);
    return(asynSuccess);
}

/* Disconnect */
static asynStatus disconnect(void *drvPvt, asynUser *pasynUser)
{
    pasynManager->exceptionDisconnect(pasynUser);
    return(asynSuccess);
}

/* for ioc shell commands for init and configure */

static const iocshArg initArg0 = { "portName",iocshArgString};
static const iocshArg initArg1 = { "Carrier",iocshArgInt};
static const iocshArg initArg2 = { "Slot",iocshArgInt};
static const iocshArg initArg3 = { "intVec",iocshArgInt};
static const iocshArg * const initArgs[4] = {&initArg0,
                                             &initArg1,
                                             &initArg2,
                                             &initArg3};
                                              
static const iocshFuncDef initFuncDef = {"initTip114",4,initArgs};
static void initCallFunc(const iocshArgBuf *args)
{
    initTip114(args[0].sval, args[1].ival, args[2].ival, args[3].ival);
}

static const iocshArg configArg0 = { "portName",iocshArgString};
static const iocshArg configArg1 = { "Channel No",iocshArgInt};
static const iocshArg configArg2 = { "No Bits",iocshArgInt};
static const iocshArg configArg3 = { "Clock Speed",iocshArgInt};
static const iocshArg configArg4 = { "Gray",iocshArgString};
static const iocshArg configArg5 = { "Parity",iocshArgString};
static const iocshArg configArg6 = { "Add Clk cycle",iocshArgInt};

static const iocshArg * configArgs[7] = {&configArg0,
                                         &configArg1,
                                         &configArg2,
                                         &configArg3,
                                         &configArg4,
                                         &configArg5,
                                         &configArg6};

static const iocshFuncDef configFuncDef = {"configTip114",7,configArgs};
static void configCallFunc(const iocshArgBuf *args)
{
    configTip114(args[0].sval, args[1].ival, args[2].ival,args[3].ival,
                args[4].sval, args[5].sval,args[6].ival);
}

void tip114Register(void)
{
    iocshRegister(&initFuncDef,initCallFunc);
    iocshRegister(&configFuncDef,configCallFunc);
}

epicsExportRegistrar(tip114Register);

