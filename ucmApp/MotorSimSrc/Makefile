TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#==================================================

PROD_IOC = motorSim


# motorSim.dbd will be created and installed
DBD += motorSim.dbd

# motorSim.dbd will be made up from these files:
motorSim_DBD += base.dbd

motorSim_DBD += asyn.dbd

motorSim_DBD += motorSupport.dbd
motorSim_DBD += motorSimSupport.dbd





motorSim_LIBS += motorSimSupport
motorSim_LIBS += motor
motorSim_LIBS += asyn

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
motorSim_SRCS += motorSim_registerRecordDeviceDriver.cpp

motorSim_SRCS_DEFAULT += motorSimMain.cpp
motorSim_SRCS_vxWorks += -nil-

# The following adds support from base/src/vxWorks
#motorSim_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary


# Finally link to the EPICS Base libraries
motorSim_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

# SCRIPTS += motorSimTest.boot
#DB += motorSimTest.db

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

