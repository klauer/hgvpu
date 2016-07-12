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
#ipacAddCarrier( &xy9660,"0x0000")

## Initialize IP330 ADC
##  portName,Carrier,Slot,typeString,rangeString,firstChan,lastChan,intVec
initIp330("ai1",0,0,"S","0to5",0,31,192)
##  portName,scanMode,triggerString,microSecondsPerScan,secondsBetweenCalibrate
##        scanMode = scan mode:
##               0 = disable
##               1 = uniformContinuous
##               2 = uniformSingle
##               3 = burstContinuous (normally recommended)
##               4 = burstSingle
##               5 = convertOnExternalTriggerOnly
configIp330("ai1",1,"Input",1000,0)


# Initialize octal UART (all channels)
#  maxModules
#tyGSOctalDrv(1)
#  moduleID,RSnnn,intVector,carrier,slot
#tyGSOctalModuleInit("MOD0","RS232", 196, 0, 0)

##Initialize IP-OPTOIO-8
#initIpUnidig("io8",0,2,0)




## Load databases for undulator smart monitors
#dbLoadRecords("db/xxUndulatorSmartMon.vdb","U=U01")

## Load database for Cam Motion
dbLoadRecords("db/xxCamMotion.vdb","U=U01")
## Load database for Linear Motion
dbLoadRecords("db/xxLinearMotion.vdb","U=U01,PORT=ai1")



## asynRecord database for each link for diagnostic debugging
##dbLoadRecords("db/asynRecord.db","P=asynTyGs,R=0,PORT=L0,ADDR=0,OMAX=0,IMAX=0")




# Load record instances 


#bspExtVerbosity = 0



iocInit()

