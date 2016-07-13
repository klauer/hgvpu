TOP=../../..
include $(TOP)/configure/CONFIG

# Generate st.cmd files, and polynomial dbs for 33 iocs
POLY := $(shell ./poly-script $TOP)

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

DB += xxCamMotor.vdb
DB += xxCamAsynMotor.vdb
DB += xxTranslationMotor.vdb
DB += xxTranslationAsynMotor.vdb
DB += xxUndulatorBFWact.vdb
DB += xxUndulatorRTD.vdb
DB += xxUndulatorSmartMon.vdb
DB += xxCamMotion.vdb
DB += xxLinearMotion.vdb
DB += undulatorCommon.vdb
DB += xxCamCalibration.vdb
DB += xxRTDsum1.db
DB += UndulatorCallAlarm.vdb
DB += xxUndulatorDispAlarmSum.db
DB += UndulatorESTOPsum.vdb
DB += xxUndulatorField.vdb
DB += useg-poly-bb.db
DB += poly-bb-ao.db
DB += undulatorRTD.db
DB += xxUndulatorDisplay.vdb
DB += xxBPMCorrection.vdb
DB += xxCORcorrection.vdb
DB += undulatorSoft.db
DB += correctionSoft.db
DB += RFBU00Correction.vdb
DB += RFBU00SoftCorrection.vdb
DB += UndulatorSum.db
DB += UndulatorCorrectionSummary.vdb
DB += useg34.vdb
DB += save-reference-position.db
DB += useg1-poly.db
DB += useg2-poly.db
DB += useg3-poly.db
DB += useg4-poly.db
DB += useg5-poly.db
DB += useg6-poly.db
DB += useg7-poly.db
DB += useg8-poly.db
DB += useg9-poly.db
DB += useg10-poly.db
DB += useg11-poly.db
DB += useg12-poly.db
DB += useg13-poly.db
DB += useg14-poly.db
DB += useg15-poly.db
DB += useg16-poly.db
DB += useg17-poly.db
DB += useg18-poly.db
DB += useg19-poly.db
DB += useg20-poly.db
DB += useg21-poly.db
DB += useg22-poly.db
DB += useg23-poly.db
DB += useg24-poly.db
DB += useg25-poly.db
DB += useg26-poly.db
DB += useg27-poly.db
DB += useg28-poly.db
DB += useg29-poly.db
DB += useg30-poly.db
DB += useg31-poly.db
DB += useg32-poly.db
DB += useg33-poly.db
DB += useg34-poly.db
DB += smart_extra.db

DB += IDcommon_NewPower.db
DB += IDmotion.db
DB += IDerrors.db
DB += IDLimitSwitches.db
DB += IDMonitors.db
DB += HGVPU.db
DB += HGVPUmotors.db
DB += tews_LinearSSI.db
DB += FagorEncoders.db

DB += HGVPU_coordMotion.db 

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
