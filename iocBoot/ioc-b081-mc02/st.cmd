#######################################################################

# change directory to ioc Application Top
chdir("../..")

# ===================== Load Undlator IOC Application =================
# Load IOC Application
ld("bin/RTEMS-mvme3100/ucmIoc.obj")

# Register all support components
dbLoadDatabase( "dbd/ucmIoc.dbd")
ucmIoc_registerRecordDeviceDriver( pdbbase) 

# ===================== Set environment variables =====================
# Common environment variables
epicsEnvSet("IOC_NAME",  "UC01")
epicsEnvSet("LOCATION", "MMF")
epicsEnvSet("SEGMENT",  "3")
epicsEnvSet("PREFIX",   "USEG:${LOCATION}:HXR1")
#epicsEnvSet("PREFIX",   "USEG:${LOCATION}:${SEGMENT}50")

# Variable that determines if loading cam motion configuration
setenv("CAM_MOTION","TRUE")

# iocAdmin environment variables
epicsEnvSet("ENGINEER","Ziga Oven")

# Adding to the useful abbreviations. NB: no () here (that executes the cmd!)
rr=bsp_reset

# Need to do the following before any driver/device support initialization:
# ===================== GeneralTime Hack =============================
osdTimeRegister()
generalTimeReport(2)

# ===================== HW initialization ============================
cexpsh(pathSubstitute("iocBoot/%H/init_VME_hardware.cmd"))

# ===================== Load databases ===============================

# Load iocAdmin database which reports on ioc health
iocshCmd("dbLoadRecords(\"db/iocAdminRTEMS.db\", \"IOC=IOC:${LOCATION}:${IOC_NAME}\")")
iocshCmd("dbLoadRecords(\"db/iocRelease.db\", \"IOC=IOC:${LOCATION}:${IOC_NAME}\")")

# Load database for cam motion
getenv("CAM_MOTION") && iocshCmd("dbLoadRecords(\"db/camMotion.db\", \"U=${PREFIX}\")")


# Load database for HGVPU motion
iocshCmd("dbLoadRecords(\"db/hgvpuMotion.db\", \"U=${PREFIX}\")")


#!#DEBUGGGING 
#!iocshCmd("dbLoadRecords(\"db/asynRecord.db\",\"P=${PREFIX}:ASYN,R=HGU_1,PORT=M1_USW,ADDR=0,IMAX=0,OMAX=0\")")
#!iocshCmd("dbLoadRecords(\"db/asynRecord.db\",\"P=${PREFIX}:ASYN,R=HGU_2,PORT=M2_DSW,ADDR=0,IMAX=0,OMAX=0\")")
#!iocshCmd("dbLoadRecords(\"db/asynRecord.db\",\"P=${PREFIX}:ASYN,R=HGU_3,PORT=M3_DSA,ADDR=0,IMAX=0,OMAX=0\")")
#!iocshCmd("dbLoadRecords(\"db/asynRecord.db\",\"P=${PREFIX}:ASYN,R=HGU_4,PORT=M4_USA,ADDR=0,IMAX=0,OMAX=0\")")


# Load databases for RTD temperature monitors
#!iocshCmd("dbLoadRecords(\"db/undulatorRTD.db\", \"U=${PREFIX},PORT=ai1\")")
#!iocshCmd("dbLoadRecords(\"db/xxUndulatorRTD.vdb\", \"U=${PREFIX}\")")

# Load databases for undulator smart monitors
#!iocshCmd("dbLoadRecords(\"db/xxUndulatorSmartMon.vdb\", \"U=${PREFIX}, B=BFW:${LOCATION}:${SEGMENT}10, PORT1=io8, PORT2=ai1\")")

# Load database for autosave/restore status pv's
iocshCmd("dbLoadRecords(\"db/save_restoreStatus.db\", \"P=IOC:${LOCATION}:${IOC_NAME}:\")")

# ===================== Load unique items for undulator segment ======
cexpsh(pathSubstitute("iocBoot/%H/st-unique.cmd"))

# ===================== Autosave/restore Settings ====================
iocshCmd("save_restoreSet_status_prefix(\"IOC:${LOCATION}:${IOC_NAME}:\")")
save_restoreSet_IncompleteSetsOk(1)
save_restoreSet_DatedBackupFiles(1)
set_requestfile_path("/data/autosave-req") 
set_requestfile_path("./")
set_savefile_path("/data","autosave")
set_pass0_restoreFile("info_positions.sav")
set_pass0_restoreFile("info_settings.sav")

# ===================== Access Security Configuration ================
#getenv("ACF_INIT") && cexpsh( getenv("ACF_INIT"), 0 )

# ====================================================================
# Initialize/Start the EPICS Kernel
iocInit()
# ====================================================================

# ===================== Load unique items post iocBoot ===============
cexpsh(pathSubstitute("iocBoot/%H/st-offsets.cmd"))
cexpsh(pathSubstitute("iocBoot/%H/st-post-unique.cmd"))

# ===================== caPutLogging configuration ===================
# Log values only on change to the iocLogServer:
caPutLogInit("172.27.8.31:7004")
caPutLogShow(2)

# ===================== Start autosave routines ======================
# Handle autosave 'commands' contained in loaded databases.
# change directory to ioc startup area
chdir("/data/autosave-req")
iocshCmd("makeAutosaveFiles()")

# Create autsave monitors
iocshCmd("create_monitor_set(\"info_positions.req\", 5, \"U=${PREFIX}, B=BFW:${LOCATION}:${SEGMENT}10\")")
iocshCmd("create_monitor_set(\"info_settings.req\", 30, \"U=${PREFIX}\")")

# ===================== Start sequence programs ======================
getenv("CAM_MOTION") && iocshCmd("seq( &camCal, \"S=${PREFIX}\")")
# ===================== Load Sequence Program For Gap Control ========
iocshCmd("seq(setGap, \"DEV=${PREFIX}, PORT=M1_USW\")")
