#==============================================================
#
#  Abs:  IOC pre-startup initialization (Development)
#
#  Name: pre_st.cmd
#
#  Facility: LCLS Controls
#
#  Auth: 05-Jun-2007, Author's Name  (USERNAME)
#  Rev:  dd-mmm-yyyy, Reviewer's Name (USERNAME)
#--------------------------------------------------------------
#  Mod:
#       dd-mmm-yyyy, Firstname Lastname (USERNAME):
#         comment
#
#==============================================================
#
# use the DEV proxy IP address
epicsEnvSet ("SLC_PROXY_IP",      "134.79.51.39")

# use the SLAC NTP server
epicsEnvSet ("EPICS_TS_NTP_INET", "134.79.16.9")

# use the MCCDEV CA ports
epicsEnvSet ("EPICS_CA_SERVER_PORT",   "5066")
epicsEnvSet ("EPICS_CA_REPEATER_PORT", "5067")
epicsEnvSet ("LAVC","134.79.48.15")

# start the iocLogClient so messages are sent to iocLogAndFwdServer
epicsEnvSet ("EPICS_IOC_LOG_PORT", "7004")
epicsEnvSet ("EPICS_IOC_LOG_INET", "134.79.219.12")

# setup environment variables for NFS files
epicsEnvSet ("SLC_DATA","/vol/vol2/g.lcls.dev/slc")
epicsEnvSet ("NFS_IOC_DATA","/vol/vol2/g.lcls.dev/epics/ioc/data")
epicsEnvSet ("SLC_NFS_FILE_SYSTEM","8412.2211@134.79.127.51")
epicsEnvSet ("NFS_FILE_SYSTEM","8412.2211@134.79.127.51")

# start the iocLogClient
#iocLogInit()

# End of script
