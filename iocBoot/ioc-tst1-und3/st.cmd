#
# file:                st.cmd
# purpose:             EPICS Startup script for Undulator Control server, using RTEMS
# created:             20-Jan-2008
# property of:         Stanford Linear Accelerator Center,
#
# revision history:
#   20-Jan-2008        Arturo Alarcon             initial version
#

ld( "bin/ucmIoc.obj")

## Set common environment variables
< dev/pre_st.cmd
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
tyGSOctalModuleInit("MOD0","RS232", 196, 0, 1)

##Initialize IP-OPTOIO-8
#initIpUnidig("io8",0,2,0)

##Create serial port for Animatics Smart Motor - Cam #1
#  devName,moduleID,port,rdBufSize,wrBufSize
tyGSOctalDevCreate("/tyGS:0:","MOD0",-1,1000,1000)
drvAsynSerialPortConfigure("L0","/tyGS:0:0",0,0,0)
## Configure serial port parameters
asynSetOption("L0", -1, "baud", "9600")
asynSetOption("L0", -1, "bits", "8")
asynSetOption("L0", -1, "parity", "none")
asynSetOption("L0", -1, "stop", "1")
asynSetOption("L0", -1, "clocal", "Y")
asynSetOption("L0", -1, "crtscts", "N")
asynSetTraceIOMask("L0", -1, 2)
asynSetTraceMask("L0", -1, 0x1)


##Create serial port for Animatics Smart Motor - Cam #2
drvAsynSerialPortConfigure("L1","/tyGS:0:1",0,0,0)
## Configure serial port parameters
asynSetOption("L1", -1, "baud", "9600")
asynSetOption("L1", -1, "bits", "8")
asynSetOption("L1", -1, "parity", "none")
asynSetOption("L1", -1, "stop", "1")
asynSetOption("L1", -1, "clocal", "Y")
asynSetOption("L1", -1, "crtscts", "N")
asynSetTraceIOMask("L1", -1, 2)
asynSetTraceMask("L1", -1, 0x1)


##Create serial port for Animatics Smart Motor - Cam #3
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


##Create serial port for Animatics Smart Motor - Cam #4
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


##Create serial port for Animatics Smart Motor - Cam #5
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

##Setup/Configure SmartMotor paramaters
#SmartMotorSetup(5,7)
#SmartMotorConfig(0,"L0")
#SmartMotorConfig(1,"L1")
#SmartMotorConfig(2,"L2")
#SmartMotorConfig(3,"L3")
#SmartMotorConfig(4,"L4")
#SmartMotorConfig(5,"L5")
#SmartMotorConfig(6,"L6")

iocshCmd("SmartMotorSetup(5,5)")
iocshCmd("SmartMotorConfig(0,L0)")
iocshCmd("SmartMotorConfig(1,L1)")
iocshCmd("SmartMotorConfig(2,L2)")
iocshCmd("SmartMotorConfig(3,L3)")
iocshCmd("SmartMotorConfig(4,L4)")

## Load motor records
dbLoadRecords("db/undulatorCommon.vdb")
dbLoadRecords("db/xxUndulatorMotor.vdb","U=U01,M=CM1,MDESC=CAM1,card=C0,addr=S0")
dbLoadRecords("db/xxUndulatorMotor.vdb","U=U01,M=CM2,MDESC=CAM2,card=C1,addr=S0")
dbLoadRecords("db/xxUndulatorMotor.vdb","U=U01,M=CM3,MDESC=CAM3,card=C2,addr=S0")
dbLoadRecords("db/xxUndulatorMotor.vdb","U=U01,M=CM4,MDESC=CAM4,card=C3,addr=S0")
dbLoadRecords("db/xxUndulatorMotor.vdb","U=U01,M=CM5,MDESC=CAM5,card=C4,addr=S0")
#dbLoadRecords("db/xxUndulatorMotor.vdb","U=U01,M=TM1,MDESC=TM1,card=C5,addr=S0")
#dbLoadRecords("db/xxUndulatorMotor.vdb","U=U01,M=TM2,MDESC=TM2,card=C6,addr=S0")

## Load database for Cam Motion
dbLoadRecords("db/xxCamMotion.vdb","U=U01")

## Load database for Linear Motion
dbLoadRecords("db/xxLinearMotion.vdb","U=U01")

## Load databases for undulator smart monitors
#dbLoadRecords("db/xxUndulatorSmartMon.vdb","U=U01")

## asynRecord database for each link for diagnostic debugging
##dbLoadRecords("db/asynRecord.db","P=asynTyGs,R=0,PORT=L0,ADDR=0,OMAX=0,IMAX=0")




# Load record instances 


#bspExtVerbosity = 0



#iocInit()

