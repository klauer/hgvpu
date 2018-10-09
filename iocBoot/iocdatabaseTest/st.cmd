#!../../bin/rhel6-x86_64/ucmSoft

< envPaths

cd "${TOP}"

## Register all support components
dbLoadDatabase "dbd/ucmSoft.dbd"
ucmSoft_registerRecordDeviceDriver pdbbase

## Load record instances
dbLoadRecords "db/hgvpuMotion.db", "U=test"

cd "${TOP}/iocBoot/${IOC}"
iocInit

dbpf test:DebugLevel 1
epicsThreadSleep(5)

seq setGap, "DEV=test"

