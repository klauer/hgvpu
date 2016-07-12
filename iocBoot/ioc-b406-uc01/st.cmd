# change directory to ioc Application Top
chdir("../..")

# Load IOC Application
ld("bin/RTEMS-mvme3100/ucmIoc.obj")

# Register all support components
dbLoadDatabase( "dbd/ucmIoc.dbd")
ucmIoc_registerRecordDeviceDriver( pdbbase) 

# ------------------------------------------------------------------------
## Set common environment variables
epicsEnvSet("IOC_NAME",  "UC01")
epicsEnvSet("LOCA_NAME", "B406")

# Setup for iocAdmin:
epicsEnvSet("ENGINEER","Arturo Alarcon")
epicsEnvSet("LOCATION","B406-UIR-01")
# ------------------------------------------------------------------------

# Adding to the useful abbreviations. NB: no () here (that executes the cmd!)
rr=bsp_reset

# This section will begin all the initialization of routines, drivers, 
# device support, etc... We will also do configuration
# Need to do the following before any driver/device support initialization:
# ===================== Begin GeneralTime Hack =============================
osdTimeRegister()
generalTimeReport(2)
# ===================== End GeneralTime Hack ===============================

# Initialize IP carrier
bspExtVerbosity=0
ipacAddXy9660("0x0,1 A=1,D00000")

# ---------------------------------------------------------------
# Allocate the number of tyGSOctal modules to support.
# ---------------------------------------------------------------
# tyGSOctalDrv(maxModules), where  maxModules is the maximum
# number of modules to support.
tyGSOctalDrv(1)

# Initialize octal UART (all channels)
# ----------------------------
# tyGSOctalModuleInit(char *moduleID, char *ModuleType, int irq_num,
#                     char *carrier#, int slot#)
#   moduleID   - assign the IP module a name for future reference. 
#   ModuleType - "RS232", "RS422", or "RS485".
#   irq_num    - interrupt request number/vector.
#   carrier#   - carrier# assigned from the ipacAddCarrierType() call.
#   slot#      - slot number on carrier; slot[A,B,C,D] -> slot#[0,1,2,3].
tyGSOctalModuleInit("MOD0","RS232", 196, 0, 0)

##Initialize IP-OPTOIO-8
initIpUnidig("io8",0,1,0)

## Initialize IP330 ADC
##  portName,Carrier,Slot,typeString,rangeString,firstChan,lastChan,intVec
initIp330("ai1",0,2,"S","0to5",0,31,192)
##  portName,scanMode,triggerString,microSecondsPerScan,secondsBetweenCalibrate
##        scanMode = scan mode:
##               0 = disable
##               1 = uniformContinuous
##               2 = uniformSingle
##               3 = burstContinuous (normally recommended)
##               4 = burstSingle
##               5 = convertOnExternalTriggerOnly
configIp330("ai1",1,"Input",1000,0)


# ========================================================================
#  Create tty devices.
# -------------------------------------------------------------------------
# tyGSOctalDevCreate(char *portname, int moduleID, int port#, int rdBufSize,
#                    int wrtBufSize)
#   portname   - assign the port a name for future reference.
#   moduleID   - moduleID from the tyGSOctalModuleInit() call.
#   port#      - port number for this module [0-7].
#   rdBufSize  - read buffer size, in bytes.
#   wrtBufSize - write buffer size, in bytes.
# -----------------------------------------------------------------------
## Create RS232 Octal Device for Animatics Smart Motors:
## tyGSOctalDevCreate(devName,moduleID,port,rdBufSize,wrBufSize)
tyGSOctalDevCreate("/tyGS:0:","MOD0",-1,1000,1000)


# Now it is time to the asyn layer of software:
# Use drvAsynSerialPortConfigure
# drvAsynSerialPortConfigure("portName","ttyName",priority,noAutoConnect,noProcessEosIn)
# where the arguments are:
#    * portName - The portName that is registered with asynGpib.
#    * ttyName - The name of the local serial port (e.g. "/dev/ttyS0").
#    * priority - Priority at which the asyn I/O thread will run. If this is zero or missing,then
#      epicsThreadPriorityMedium is used.
#    * addr - This argument is ignored since serial devices are configured with multiDevice=0.
#    * noAutoConnect - Zero or missing indicates that portThread should automatically connect. Non-zero if
#      explicit connect command must be issued.
#    * noProcessEos If 0 then asynInterposeEosConfig is called specifying both processEosIn and processEosOut.

# Don't forget to setup asynSetOption
# asynSetOption("portName",addr,"key","value")
# The following parameters are for the "key"  "value" pairs
# baud   9600 50 75 110 134 150 200 300 600 1200 ... 230400
# bits  8 7 6 5
# parity  none even odd
# stop  1 2
# clocal  Y N
# crtscts  N Y

# The clocal and crtscts parameter names are taken from the POSIX termios serial interface definition. The clocal # parameter controls whether the modem control lines (Data Terminal Ready, Carrier Detect/Received Line Signal #Detect) are used (clocal=N) or ignored (clocal=Y). The crtscts parameter controls whether the hardware #handshaking lines (Request To Send, Clear To Send) are used (crtscts=Y) or ignored (crtscts=N).


# Now what about Debugging:
# asynSetTraceIOMask(portName,addr,mask)
# asynSetTraceMask(portName,addr,mask)
# asynReport(level,portName)

## Create serial port for Animatics Smart Motor - Cam #1
drvAsynSerialPortConfigure("L0","/tyGS:0:0",0,0,0)
## Configure serial port parameters
asynSetOption("L0", -1, "baud", "9600")
asynSetOption("L0", -1, "bits", "8")
asynSetOption("L0", -1, "parity", "none")
asynSetOption("L0", -1, "stop", "1")
asynSetOption("L0", -1, "clocal", "Y")
asynSetOption("L0", -1, "crtscts", "N")

# For Debugging uncomment the following:
#asynSetTraceIOMask("L0", 0, 2)
#asynSetTraceMask("L0", 0, 0x19)

## Create serial port for Animatics Smart Motor - Cam #2
## tyGSOctalDevCreate(devName,moduleID,port,rdBufSize,wrBufSize)
drvAsynSerialPortConfigure("L1","/tyGS:0:1",0,0,0)
## Configure serial port parameters
asynSetOption("L1", -1, "baud", "9600")
asynSetOption("L1", -1, "bits", "8")
asynSetOption("L1", -1, "parity", "none")
asynSetOption("L1", -1, "stop", "1")
asynSetOption("L1", -1, "clocal", "Y")
asynSetOption("L1", -1, "crtscts", "N")

# For Debugging uncomment the following:
#asynSetTraceIOMask("L1", 0, 2)
#asynSetTraceMask("L1", 0, 0x19)

## Create serial port for Animatics Smart Motor - Cam #3
## tyGSOctalDevCreate(devName,moduleID,port,rdBufSize,wrBufSize)
drvAsynSerialPortConfigure("L2","/tyGS:0:2",0,0,0)
## Configure serial port parameters
asynSetOption("L2", -1, "baud", "9600")
asynSetOption("L2", -1, "bits", "8")
asynSetOption("L2", -1, "parity", "none")
asynSetOption("L2", -1, "stop", "1")
asynSetOption("L2", -1, "clocal", "Y")
asynSetOption("L2", -1, "crtscts", "N")

# For Debugging uncomment the following:
#asynSetTraceIOMask("L2", -1, 2)
#asynSetTraceMask("L2", -1, 0x1)

## Create serial port for Animatics Smart Motor - Cam #4
## tyGSOctalDevCreate(devName,moduleID,port,rdBufSize,wrBufSize)
drvAsynSerialPortConfigure("L3","/tyGS:0:3",0,0,0)
## Configure serial port parameters
asynSetOption("L3", -1, "baud", "9600")
asynSetOption("L3", -1, "bits", "8")
asynSetOption("L3", -1, "parity", "none")
asynSetOption("L3", -1, "stop", "1")
asynSetOption("L3", -1, "clocal", "Y")
asynSetOption("L3", -1, "crtscts", "N")

# For Debugging uncomment the following:
#asynSetTraceIOMask("L3", -1, 2)
#asynSetTraceMask("L3", -1, 0x1)

## Create serial port for Animatics Smart Motor - Cam #5
## tyGSOctalDevCreate(devName,moduleID,port,rdBufSize,wrBufSize)
drvAsynSerialPortConfigure("L4","/tyGS:0:4",0,0,0)
## Configure serial port parameters
asynSetOption("L4", -1, "baud", "9600")
asynSetOption("L4", -1, "bits", "8")
asynSetOption("L4", -1, "parity", "none")
asynSetOption("L4", -1, "stop", "1")
asynSetOption("L4", -1, "clocal", "Y")
asynSetOption("L4", -1, "crtscts", "N")

# For Debugging uncomment the following:
#asynSetTraceIOMask("L4", -1, 2)
#asynSetTraceMask("L4", -1, 0x1)

## Create serial port for Animatics Smart Motor - Trans #1
## tyGSOctalDevCreate(devName,moduleID,port,rdBufSize,wrBufSize)
drvAsynSerialPortConfigure("L5","/tyGS:0:5",0,0,0)
## Configure serial port parameters
asynSetOption("L5", -1, "baud", "9600")
asynSetOption("L5", -1, "bits", "8")
asynSetOption("L5", -1, "parity", "none")
asynSetOption("L5", -1, "stop", "1")
asynSetOption("L5", -1, "clocal", "Y")
asynSetOption("L5", -1, "crtscts", "N")

# For Debugging uncomment the following:
#asynSetTraceIOMask("L5", -1, 2)
#asynSetTraceMask("L5", -1, 0x1)

## Configure serial port for Animatics Smart Motor - Trans #2
## tyGSOctalDevCreate(devName,moduleID,port,rdBufSize,wrBufSize)
drvAsynSerialPortConfigure("L6","/tyGS:0:6",0,0,0)
## Configure serial port parameters
asynSetOption("L6", -1, "baud", "9600")
asynSetOption("L6", -1, "bits", "8")
asynSetOption("L6", -1, "parity", "none")
asynSetOption("L6", -1, "stop", "1")
asynSetOption("L6", -1, "clocal", "Y")
asynSetOption("L6", -1, "crtscts", "N")

# For Debugging uncomment the following:
#asynSetTraceIOMask("L6", -1, 2)
#asynSetTraceMask("L6", -1, 0x1)

## Setup SmartMotor System
## SmartMotorSetup(Max Controller Count, Polling Rate)
#SmartMotorSetup(7,5)
iocshCmd("SmartMotorSetup(7,5)")


## Setup/Configure SmartMotor parameters - CAM #1
## SmartMotorConfig("Card" #, ASYN port)
#SmartMotorConfig(0,"L0")
iocshCmd("SmartMotorConfig(0,L0)")

## Setup/Configure SmartMotor parameters - CAM #2
## SmartMotorConfig("Card" #, ASYN port)
#SmartMotorConfig(1,"L1")
iocshCmd("SmartMotorConfig(1,L1)")

## Setup/Configure SmartMotor parameters - CAM #3
## SmartMotorConfig("Card" #, ASYN port)
#SmartMotorConfig(2,"L2")
iocshCmd("SmartMotorConfig(2,L2)")

## Setup/Configure SmartMotor parameters - CAM #4
## SmartMotorConfig("Card" #, ASYN port)
#SmartMotorConfig(3,"L3")
iocshCmd("SmartMotorConfig(3,L3)")

## Setup/Configure SmartMotor parameters - CAM #5
## SmartMotorConfig("Card" #, ASYN port)
#SmartMotorConfig(4,"L4")
iocshCmd("SmartMotorConfig(4,L4)")

## Setup/Configure SmartMotor parameters - TRANS #1
## SmartMotorConfig("Card" #, ASYN port)
#SmartMotorConfig(5,"L5")
iocshCmd("SmartMotorConfig(5,L5)")

## Setup/Configure SmartMotor parameters - TRANS #2
## SmartMotorConfig("Card" #, ASYN port)
iocshCmd("SmartMotorConfig(6,L6)")

## Motor support debugging messages
#var drvSmartMotordebug 4

# ------------------------------------------------------------------------
# This section we will load all the databases 
# ------------------------------------------------------------------------

## Load iocAdmin database which reports on ioc health
dbLoadRecords("db/iocAdminRTEMS.db", "IOC=IOC:B406:UC01")
dbLoadRecords("db/iocRelease.db", "IOC=IOC:B406:UC01")

## Load cater numbers database
dbLoadRecords( "db/xxUndulatorProblems.vdb","U=USEG:B406:150,N=1")
dbLoadRecords( "db/xxUndulatorProblems.vdb","U=USEG:B406:150,N=2")
dbLoadRecords( "db/xxUndulatorProblems.vdb","U=USEG:B406:150,N=3")
dbLoadRecords( "db/xxUndulatorProblems.vdb","U=USEG:B406:150,N=4")

## Load motor records
dbLoadRecords("db/xxCamMotor.vdb","U=USEG:B406:150,M=CM1,MDESC=CAM 1,card=C0,addr=S0")
dbLoadRecords("db/xxCamMotor.vdb","U=USEG:B406:150,M=CM2,MDESC=CAM 2,card=C1,addr=S0")
dbLoadRecords("db/xxCamMotor.vdb","U=USEG:B406:150,M=CM3,MDESC=CAM 3,card=C2,addr=S0")
dbLoadRecords("db/xxCamMotor.vdb","U=USEG:B406:150,M=CM4,MDESC=CAM 4,card=C3,addr=S0")
dbLoadRecords("db/xxCamMotor.vdb","U=USEG:B406:150,M=CM5,MDESC=CAM 5,card=C4,addr=S0")
dbLoadRecords("db/xxTranslationMotor.vdb", "U=USEG:B406:150, M=TM1, MDESC=TM 1,card=C5,addr=S0")
dbLoadRecords("db/xxTranslationMotor.vdb", "U=USEG:B406:150, M=TM2, MDESC=TM 2,card=C6,addr=S0")

## Load database for Cam Motion
dbLoadRecords("db/xxCamMotion.vdb","U=USEG:B406:150, UND=U01")

## Load database for Linear Motion
dbLoadRecords("db/xxLinearMotion.vdb","U=USEG:B406:150,PORT=ai1, UND=U01")

## Load databases for RTD temperature monitors
dbLoadRecords("db/undulatorRTD.db","U=USEG:B406:150,PORT=ai1")
dbLoadRecords("db/xxUndulatorRTD.vdb","U=USEG:B406:150")

## Load databases for BFW actuator control/position monitor
dbLoadRecords("db/xxUndulatorBFWact.vdb","B=BFW:B406:110, PORT=io8")

## Load databases for undulator smart monitors
dbLoadRecords("db/xxUndulatorSmartMon.vdb","U=USEG:B406:150, B=BFW:B406:110, PORT1=io8, PORT2=ai1")

## Load databases for calibrating CAMs
dbLoadRecords("db/xxCamCalibration.vdb","U=USEG:B406:150")

## Load databases for alarm display summaries
dbLoadRecords("db/xxUndulatorDispAlarmSum.db","U=USEG:B406:150")

## Load databases for automated display options
dbLoadRecords("db/xxUndulatorDisplay.vdb","U=USEG:B406:150")

## Load databases for Undulator field calculations
dbLoadRecords("db/xxUndulatorField.vdb","U=USEG:B406:150")
#dbLoadRecords("db/useg1-poly.db")
#dbLoadRecords("db/useg-poly-bb.db", "U=USEG:B406:150, POSITION=1")
#dbLoadRecords("db/poly-bb-ao.db", "U=USEG:B406:150")

## Load databases for Undulator BPM and X-YCOR corrections
#dbLoadRecords("db/xxBPMCorrection.vdb", "U=USEG:B406:150")
#dbLoadRecords("db/xxCORcorrection.vdb", "U=USEG:B406:150, UN1=USEG:B406:250, N=1")

## asynRecord database for each link for diagnostic debugging
dbLoadRecords("db/asynRecord.db","P=USEG:B406:150:ASYN,R=CAM1,PORT=L0,ADDR=0,IMAX=0,OMAX=0")
dbLoadRecords("db/asynRecord.db","P=USEG:B406:150:ASYN,R=CAM2,PORT=L1,ADDR=0,IMAX=0,OMAX=0")
dbLoadRecords("db/asynRecord.db","P=USEG:B406:150:ASYN,R=CAM3,PORT=L2,ADDR=0,IMAX=0,OMAX=0")
dbLoadRecords("db/asynRecord.db","P=USEG:B406:150:ASYN,R=CAM4,PORT=L3,ADDR=0,IMAX=0,OMAX=0")
dbLoadRecords("db/asynRecord.db","P=USEG:B406:150:ASYN,R=CAM5,PORT=L4,ADDR=0,IMAX=0,OMAX=0")
dbLoadRecords("db/asynRecord.db","P=USEG:B406:150:ASYN,R=TRA1,PORT=L5,ADDR=0,IMAX=0,OMAX=0")
dbLoadRecords("db/asynRecord.db","P=USEG:B406:150:ASYN,R=TRA2,PORT=L6,ADDR=0,IMAX=0,OMAX=0")

## Load database for autosave/restore status pv's
dbLoadRecords("db/save_restoreStatus.db","P=IOC:B406:UC01:")

#Load unique items
< iocBoot/ioc-und1-uc01/st-unique.cmd


## autosave/restore settings
save_restoreSet_NFSHost(getenv("NFS_FILE_SYSTEM"), iocData, "/data")
save_restoreSet_status_prefix( "IOC:B406:UC01:")
save_restoreSet_IncompleteSetsOk(1)
save_restoreSet_DatedBackupFiles(1)

set_requestfile_path("/data/autosave-req") 
set_requestfile_path("./")
set_savefile_path("/data","autosave")

## ==============================================
## New method for autosave and restore
#  Decide what is saved by specifying it in the
#  EPICS databases
## =============================================
set_pass0_restoreFile("info_positions.sav")
set_pass0_restoreFile("info_settings.sav")

## =============================================

cd $(TOP)/iocBoot/$(IOC)

## Load Access Security File
#asSetFilename("db/ucmAccessControl.acf")

# Server to dump list of PVs to a pvlist client
# over the network. Not yet working
#pvlistserver("22222")

# Initialize/Start the EPICS Kernel
iocInit()


# =====================================================
# Turn on caPutLogging:
# Log values only on change to the iocLogServer:
#caPutLogInit("172.27.8.31:7004")
#caPutLogShow(2)
# =====================================================


## ===========================================================
## Start autosave routines to save our data
## ===========================================================
# optional, needed if the IOC takes a very long time to boot.
epicsThreadSleep( 1.0)

## Handle autosave 'commands' contained in loaded databases.
# change directory to ioc startup area
chdir("/data/autosave-req")
iocshCmd("makeAutosaveFiles()")

create_monitor_set("info_positions.req", 5, "U=USEG:B406:150, B=BFW:B406:110")
create_monitor_set("info_settings.req", 30, "U=USEG:B406:150")

# Let's start up our Sequencers:
#seq( &camCal, "S=USEG:B406:150")
seq( &motorMon, "S=USEG:B406:150")
seq( &bfwMon, "B=BFW:B406:110, S=USEG:B406:150")
# seq( &recovery, "S=USEG:B406:150")

# Process KDES with temp correction restored
#dbpf("USEG:B406:150:KDES.PROC","1")

# Restore undulator segment type from database
#dbpf("USEG:B406:150:CALCNOTYPE.PROC","1")
