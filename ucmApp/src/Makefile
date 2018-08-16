TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================
# build an ioc application
PROD_IOC_RTEMS = ucmIoc
PROD_HOST      = ucmSoft

# ucmSoft.dbd will be made up from these files:
DBD          = ucmSoft.dbd
ucmSoft_DBD += base.dbd
ucmSoft_DBD += iocAdmin.dbd
ucmSoft_DBD += asSupport.dbd
ucmSoft_DBD += caPutLog.dbd
ucmSoft_DBD += asyn.dbd
ucmSoft_DBD += drvAsynSerialPort.dbd
ucmSoft_DBD += motorSupport.dbd
ucmSoft_DBD += motorSimSupport.dbd
ucmSoft_DBD += devSmartMotorAsynSupport.dbd
ucmSoft_DBD += calcSupport.dbd
ucmSoft_DBD += busySupport.dbd
ucmSoft_DBD += setGap.dbd

# ucmIoc.dbd will be made up from these files:
#
ifeq ($(OS_CLASS),RTEMS)
DBD += ucmIoc.dbd
ucmIoc_DBD += base.dbd
ucmIoc_DBD += iocAdmin.dbd
ucmIoc_DBD += asSupport.dbd
ucmIoc_DBD += caPutLog.dbd
ucmIoc_DBD += asyn.dbd
ucmIoc_DBD += drvAsynSerialPort.dbd
ucmIoc_DBD += motorSupport.dbd
ucmIoc_DBD += motorSimSupport.dbd
ucmIoc_DBD += devSmartMotorAsynSupport.dbd
ucmIoc_DBD += tyGSOctal.dbd
ucmIoc_DBD += IP520.dbd
ucmIoc_DBD += ip330Support.dbd
ucmIoc_DBD += ipUnidigSupport.dbd
ucmIoc_DBD += drvIpac.dbd
ucmIoc_DBD += ucmSupport.dbd
ucmIoc_DBD += devA16Vme.dbd
ucmIoc_DBD += calcSupport.dbd
ucmIoc_DBD += busySupport.dbd
ucmIoc_DBD += softGlueSupport.dbd
ucmIoc_DBD += setGap.dbd
endif

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
ucmIoc_SRCS  += ucmIoc_registerRecordDeviceDriver.cpp
ucmSoft_SRCS += ucmSoft_registerRecordDeviceDriver.cpp
USR_SRCS_DEFAULT += ucmIocMain.cpp

# Add locally compiled object code
ifeq ($(OS_CLASS),RTEMS)
ucmIoc_SRCS += camPosCalc.c
ucmIoc_SRCS += camPosRead.c
ucmIoc_SRCS += girderRollCalc.c
ucmIoc_SRCS += quadBfwCalc.c
ucmIoc_SRCS += polynomial.c
ucmIoc_SRCS += xyCORrection.c
ucmIoc_SRCS += drvTip114.c
endif

# The following will get rid of the
# Unresolved symbol: rtemsTicksPerSecond_double
# That occurs at run time.
ifeq ($(OS_CLASS),RTEMS)

# Next, we will provide on our time provider for genralTime:
muon_SRCS += ntpProvider.cc
endif

#!#USR_LIBS  += devIocStats
#!#USR_LIBS  += autosave
#!#USR_LIBS  += caPutLog
#!##USR_LIBS  += genSub
#!#USR_LIBS  += calc
#!#USR_LIBS  += sscan
#!#USR_LIBS  += busy
#!#USR_LIBS += asyn
 
ucmSoft_LIBS += SmartMotorAsyn
ucmSoft_LIBS += softMotor
ucmSoft_LIBS += motorSimSupport
ucmSoft_LIBS += motor
ucmSoft_LIBS += devIocStats
ucmSoft_LIBS += autosave
ucmSoft_LIBS += caPutLog
ucmSoft_LIBS += calc
ucmSoft_LIBS += sscan
ucmSoft_LIBS += busy
ucmSoft_LIBS += asyn

# Add in VME drivers.
ifeq ($(OS_CLASS),RTEMS)
ucmIoc_LIBS += SmartMotorAsyn
ucmIoc_LIBS += softMotor
ucmIoc_LIBS += motorSimSupport
ucmIoc_LIBS += motor
ucmIoc_LIBS += TyGSOctal
ucmIoc_LIBS += IP520
ucmIoc_LIBS += ip330
ucmIoc_LIBS += ipUnidig
ucmIoc_LIBS += Ipac
ucmIoc_LIBS += a16Vme
ucmIoc_LIBS += softGlue
ucmIoc_LIBS += devIocStats
ucmIoc_LIBS += autosave
ucmIoc_LIBS += caPutLog
ucmIoc_LIBS += calc
ucmIoc_LIBS += sscan
ucmIoc_LIBS += busy
ucmIoc_LIBS += asyn
endif

# Build SNL programs
# NOTE: to build SLN programs, SNCSEQ must be defined
# in the <top>/configure/RELEASE file
#
ifneq ($(SNCSEQ),)
 USR_SNCFLAGS += +r
 USR SNCFLAGS += -a
 USR_SNCFLAGS += +c
 USR_SNCFLAGS += +d
 USR_SRCS += camCalibrate.st
 USR_SRCS += motorMon.st
 USR_SRCS += recovery.st
 USR_SRCS += bfwMon.st
 USR_SRCS += autoOff.st
 USR_SRCS += setGap.stt
 USR_LIBS += seq pv
endif

USR_LIBS += $(EPICS_BASE_IOC_LIBS)

#=============================
include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE
#========================================
#
# End of file
