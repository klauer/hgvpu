# Unique boot items for USEG:UND1:3450 beofre iocInit
epicsEnvSet("LOCATION","B406")

#Lens controls hardware
devA16VmeConfig(0,0x8800,20,0x00,0,7)

#Lens controls database
dbLoadRecords("db/lensctl.template", "dev1=YAGS,area1=UND1,loca1=1650,dev2=CAMR,area2=UND1,loca2=1650")

# Add items for SXRSS needed before iocInit
# 
##  portName,Carrier,Slot,typeString,rangeString,firstChan,lastChan,intVec
initIp330("ai2",0,3,"D","0to5",0,1,194)
##  portName,scanMode,triggerString,microSecondsPerScan,secondsBetweenCalibrate
##        scanMode = scan mode:
##               0 = disable
##               1 = uniformContinuous
##               2 = uniformSingle
##               3 = burstContinuous (normally recommended)
##               4 = burstSingle
##               5 = convertOnExternalTriggerOnly
configIp330("ai2",1,"Input",1000,0)

## Motor simulation configuration (port, numAxes)
motorSimCreateController("motorSim1", 2)

## motorSimConfigAxis(port, axis, lowLimit, highLimit, home, start)
motorSimConfigAxis("motorSim1", 0, 20000, -20000,  500, 0)
motorSimConfigAxis("motorSim1", 1, 20000, -20000,  500, 0)

dbLoadRecords("db/sxrss.db", "seg=34")
