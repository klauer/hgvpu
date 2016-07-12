#!../../bin/linux-x86/ucmSoft
#==============================================================
#
#  Abs:  Startup Script for the undulator motion soft ioc
#
#  Name: st.cmd
#
#  Facility:  LCLS Undulator Controls
#
#  Auth: 08-Sep-2010, Arturo Alarcon  (ALARCON)
#  Rev:  dd-mmm-yyyy, Reviewer's Name (USERNAME)
#--------------------------------------------------------------
#  Mod:
#       dd-mmm-yyyy, First Last name  (USERNAME):
#         comment
#
#==============================================================


# Source envPaths
< envPaths

# Change directory to TOP of application
cd ${TOP}

## Register all support components
dbLoadDatabase("dbd/ucmSoft.dbd",0,0)
ucmSoft_registerRecordDeviceDriver(pdbbase)

# For iocAdmin
epicsEnvSet("ENGINEER","A. Alarcon") 
epicsEnvSet("LOCATION","lcls-daemon1") 
epicsEnvSet("STARTUP","/usr/local/lcls/epics/iocCommon/sioc-und1-uc01") 
epicsEnvSet("ST_CMD","startup.cmd") 

## Load record instances
dbLoadRecords("db/iocAdminSoft.db","IOC=SIOC:UND1:UC01")
dbLoadRecords("db/iocRelease.db", "IOC=SIOC:UND1:UC01")
dbLoadRecords("db/UndulatorCallAlarm.vdb")
dbLoadRecords("db/xxRTDsum1.db")
dbLoadRecords("db/UndulatorSum.db")
dbLoadRecords("db/UndulatorCorrectionSummary.vdb")
dbLoadRecords("db/undulatorSoft.db")
dbLoadRecords("db/useg34.vdb")
dbLoadRecords("db/correctionSoft.db")
dbLoadRecords("db/RFBU00SoftCorrection.vdb","PLANE=X")
dbLoadRecords("db/RFBU00SoftCorrection.vdb","PLANE=Y")

## Load database for autosave/restore status pv's
dbLoadRecords("db/save_restoreStatus.db","P=SIOC:UND1:UC01:")

## autosave/restore settings
save_restoreSet_status_prefix( "SIOC:UND1:UC01:")
save_restoreSet_IncompleteSetsOk(1)
save_restoreSet_DatedBackupFiles(1)

set_requestfile_path("${IOC_DATA}/sioc-und1-uc01/autosave-req") 
set_requestfile_path("./")
set_savefile_path("${IOC_DATA}/sioc-und1-uc01","autosave")

## ==============================================
## New method for autosave and restore
#  Decide what is saved by specifying it in the
#  EPICS databases
## =============================================
set_pass0_restoreFile("info_positions.sav")
set_pass0_restoreFile("info_settings.sav")

## =============================================

# Initialize IOC
iocInit()

## ===========================================================
## Start autosave routines to save our data
## ===========================================================
# optional, needed if the IOC takes a very long time to boot.
epicsThreadSleep( 1.0)

## Handle autosave 'commands' contained in loaded databases.
# change directory to ioc startup area
cd ${IOC_DATA}/sioc-und1-uc01/autosave-req
iocshCmd("makeAutosaveFiles()")

create_monitor_set("info_positions.req", 5)
create_monitor_set("info_settings.req", 30)
