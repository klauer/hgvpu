#
# file:                st.cmd
# purpose:             EPICS Startup script for Undulator Control server, using RTEMS
# created:             20-Jan-2008
# property of:         Stanford Linear Accelerator Center,
#
# revision history:
#   20-Jan-2008        Arturo Alarcon             initial version
#

#chdir("../..")

ld("bin/ucmIoc.obj")

## Set common environment variables
< pre_st.cmd
#epicsEnvSet("IOC_NAME",  "MC20")
#epicsEnvSet("LOCA_NAME", "IN20")

# Setup NFS mounts 
nfsMount(getenv("NFS_FILE_SYSTEM"),getenv("NFS_IOC_DATA"),"/dat")

# Adding to the useful abbreviations. NB: no () here (that executes the cmd!)
rr = rtemsReboot

# epicsEnvSet( "EPICS_CA_MAX_ARRAY_BYTES", "30000")

# Register all support components
dbLoadDatabase( "dbd/ucmIoc.dbd")
ucmIoc_registerRecordDeviceDriver( pdbbase) 

# Initialize IP carrier
bspExtVerbosity=0
ipacAddXy9660("0x0,1 A=1,D00000")

# initialize IP330
#ip330Create("ai1", 0, 0, "0to5D", "ch0-ch7", 0x00, 0x00, "uniformCont-Input-Avg10R", "64*5@8MHz", 0x66)

# Initialize octal UART (all channels)
#  maxModules
tyGSOctalDrv(1)
#  moduleID,RSnnn,intVector,carrier,slot
tyGSOctalModuleInit("MOD0","RS232", 196, 0, 0)

##Initialize IP-OPTOIO-8
#initIpUnidig("io8",0,2,0)


## Create serial port for Animatics Smart Motor - Cam #1
## tyGSOctalDevCreate(devName,moduleID,port,rdBufSize,wrBufSize)
tyGSOctalDevCreate("/tyGS:0:","MOD0",-1,1000,1000)


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
asynSetTraceIOMask("L1", 0, 2)
asynSetTraceMask("L1", 0, 0x19)


drvAsynSerialPortConfigure("L0","/tyGS:0:0",0,0,0)
## Configure serial port parameters
asynSetOption("L0", -1, "baud", "9600")
asynSetOption("L0", -1, "bits", "8")
asynSetOption("L0", -1, "parity", "none")
asynSetOption("L0", -1, "stop", "1")
asynSetOption("L0", -1, "clocal", "Y")
asynSetOption("L0", -1, "crtscts", "N")
asynSetTraceIOMask("L0", 0, 2)
asynSetTraceMask("L0", 0, 0x19)


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
asynSetTraceIOMask("L2", -1, 2)
asynSetTraceMask("L2", -1, 0x1)

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
asynSetTraceIOMask("L3", -1, 2)
asynSetTraceMask("L3", -1, 0x1)

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
asynSetTraceIOMask("L4", -1, 2)
asynSetTraceMask("L4", -1, 0x1)

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
asynSetTraceIOMask("L5", -1, 2)
asynSetTraceMask("L5", -1, 0x1)

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
asynSetTraceIOMask("L6", -1, 2)
asynSetTraceMask("L6", -1, 0x1)

## Setup/Configure SmartMotor parameters - CAM #1
## SmartMotorSetup(Max Controller Count, Polling Rate)
#SmartMotorSetup(7,5)
iocshCmd("SmartMotorSetup(5,5)")

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
#SmartMotorConfig(5,"L5")

## Setup/Configure SmartMotor parameters - TRANS #2
## SmartMotorConfig("Card" #, ASYN port)
#SmartMotorConfig(6,"L6")

## Motor support debugging messages
#var drvSmartMotordebug 4


## Load motor records
#dbLoadRecords("db/undulatorCommon.vdb","U=U01")

dbLoadRecords("db/xxCamMotor.vdb","U=U01,M=CM2,MDESC=CAM 2,card=C1,addr=S0")
dbLoadRecords("db/xxCamMotor.vdb","U=U01,M=CM1,MDESC=CAM 1,card=C0,addr=S0")
dbLoadRecords("db/xxCamMotor.vdb","U=U01,M=CM3,MDESC=CAM 3,card=C2,addr=S0")
dbLoadRecords("db/xxCamMotor.vdb","U=U01,M=CM4,MDESC=CAM 4,card=C3,addr=S0")
dbLoadRecords("db/xxCamMotor.vdb","U=U01,M=CM5,MDESC=CAM 5,card=C4,addr=S0")
#dbLoadRecords("db/xxTranslationMotor.vdb", "U=U01, M=TM1, MDESC=TM 1,card=C5,addr=S0")
#dbLoadRecords("db/xxTranslationMotor.vdb", "U=U01, M=TM2, MDESC=TM 2,card=C6,addr=S0")

## Load database for Cam Motion
#dbLoadRecords("db/xxCamMotion.vdb","U=U01")

## Load database for Linear Motion
#dbLoadRecords("db/xxLinearMotion.vdb","U=U01,PORT=ai1")

## Load databases for RTD temperature monitors
#dbLoadRecords("db/xxUndulatorRTD.vdb","U=U01,PORT=ai1")

## Load databases for BFW actuator control/position monitor
#dbLoadRecords("db/xxUndulatorBFWact.vdb","U=U01, PORT=io8")

## Load databases for undulator smart monitors
#dbLoadRecords("db/xxUndulatorSmartMon.vdb","U=U01, PORT1=io8, PORT2=ai1")

## Load databases for calibrating CAMs
#dbLoadRecords("db/xxCamCalibration.vdb","U=U01")

## asynRecord database for each link for diagnostic debugging
#dbLoadRecords("db/asynRecord.db","P=asyn,R=CAM1,PORT=L0,ADDR=0,IMAX=0,OMAX=0")
#dbLoadRecords("db/asynRecord.db","P=asyn,R=CAM2,PORT=L1,ADDR=0,IMAX=0,OMAX=0")
#dbLoadRecords("db/asynRecord.db","P=asyn,R=CAM3,PORT=L2,ADDR=0,IMAX=0,OMAX=0")
#dbLoadRecords("db/asynRecord.db","P=asyn,R=CAM4,PORT=L3,ADDR=0,IMAX=0,OMAX=0")
#dbLoadRecords("db/asynRecord.db","P=asyn,R=CAM5,PORT=L4,ADDR=0,IMAX=0,OMAX=0")
#dbLoadRecords("db/asynRecord.db","P=asyn,R=TRA1,PORT=L5,ADDR=0,IMAX=0,OMAX=0")
#dbLoadRecords("db/asynRecord.db","P=asyn,R=TRA2,PORT=L6,ADDR=0,IMAX=0,OMAX=0")

## Load database for autosave/restore status pv's
#dbLoadRecords("db/save_restoreStatus.db","P=U01:")

## autosave/restore settings
#save_restoreSet_IncompleteSetsOk(1)
#save_restoreSet_DatedBackupFiles(0)
#set_requestfile_path("./")
#set_savefile_path("./saverestore")
#set_pass0_restoreFile("ucmAutosaveV1.sav")
#set_pass1_restoreFile("ucmAutosaveV1.sav")

#cd ${TOP}/iocBoot/${IOC}

## Load Access Security File
#asSetFilename("../../ascf/ucmAccessControl.acf")

#iocInit()

## SET CAM CALIBRATION VALUES - TEMPORARY
#dbpf "U01:CM1:ZeroOffsetC","-131.6"
#dbpf "U01:CM1:GainC","345.5"
#dbpf "U01:CM2:ZeroOffsetC","44.6"
#dbpf "U01:CM2:GainC","347.2"
#dbpf "U01:CM3:ZeroOffsetC","71.5"
#dbpf "U01:CM3:GainC","346.8"
#dbpf "U01:CM4:ZeroOffsetC","-71.9"
#dbpf "U01:CM4:GainC","345.2"
#dbpf "U01:CM5:ZeroOffsetC","21.7"
#dbpf "U01:CM5:GainC","346.9"

#create_monitor_set("ucmAutosaveV1.req", 60, "U=U01")

#seq &camCal, "S=U01"
