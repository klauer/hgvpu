TOP=../../..
include $(TOP)/configure/CONFIG

# Generate st.cmd files, and polynomial dbs for 33 iocs
#POLY := $(shell ./poly-script $TOP)

#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE

#----------------------------------------------------
#  Optimization of db files using dbst (DEFAULT: NO)
#DB_OPT = YES

# Rules for installing autosave/restore request files:
# No effort was made for autosave/restore of new PVs for HGVPU
# at this time ... some PVs should be added though
CFG +=  CONFIG_SECURITY

#----------------------------------------------------
# Create and install (or just install)
# databases, templates, substitutions like this

DB += xxUndulatorRTD.vdb
DB += xxUndulatorSmartMon.vdb
DB += xxLinearMotion.vdb
DB += undulatorCommon.vdb
DB += xxRTDsum1.db
DB += UndulatorCallAlarm.vdb
DB += UndulatorESTOPsum.vdb
DB += undulatorRTD.db
DB += undulatorSoft.db
DB += correctionSoft.db
DB += RFBU00Correction.vdb
DB += RFBU00SoftCorrection.vdb
DB += UndulatorSum.db
DB += UndulatorCorrectionSummary.vdb
DB += useg34.vdb

DB += hgvpuMotion.db
#  hgvpuMotion inflates follwing dbs for HGVPU system moton:
#DB += HGVPU.db
#DB += HGVPU_masterMotorStatus.db
#DB += HGVPU_real_motor.db
#DB += HGVPU_virt_motor.db
#DB += smart_extra.db
#DB += IDcommon_NewPower.db
#DB += IDLimitSwitches.db
#DB += IDmotion.db
#DB += IDMonitors.db
#DB += IDerrors.db
#DB += ID_FPGArev.db
#DB += FagorEncoders.template
#DB += tews_LinearSSI.db

DB += camMotion.db
# camMotion inflates following dbs for CAM system motion:
#DB += xxCamMotor.vdb
#DB += xxCamAsynMotor.vdb
#DB += xxTranslationMotor.vdb
#DB += xxTranslationAsynMotor.vdb
#DB += xxCamMotion.vdb
#DB += xxCamCalibration.vdb
#DB += xxUndulatorDispAlarmSum.db
#DB += save-reference-position.db

# LCLS specific databases
#DB += xxUndulatorField.vdb
#DB += useg-poly-bb.db
#DB += poly-bb-ao.db
#DB += xxBPMCorrection.vdb
#DB += xxCORcorrection.vdb
#DB += xxUndulatorBFWact.vdb
#DB += xxUndulatorDisplay.vdb

# ==========================================
# Install autosave/restore request files
SECURITY += ucmAccessControl.acf
# =========================================

DB_INSTALLS += $(ASYN)/db/asynRecord.db
DB_INSTALLS += $(AUTOSAVE)/db/save_restoreStatus.db
DB_INSTALLS += $(IOCADMIN)/db/iocAdminRTEMS.db
DB_INSTALLS += $(IOCADMIN)/db/iocAdminSoft.db
IOCRELEASE_DB += iocRelease.db

#----------------------------------------------------
# If <anyname>.db template is not named <anyname>*.template add
# <anyname>_TEMPLATE = <templatename>

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE
