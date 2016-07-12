# Add items for SXRSS needed before iocInit
# 
## Needed for Grating-M1 X pot
## Initialize IP330 ADC
##  portName,Carrier,Slot,typeString,rangeString,firstChan,lastChan,intVec
initIp330("ai2",0,3,"D","0to5",0,1,194)
#initIp330("ai2",0,3,"S","0to5",0,31,192)
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

#load SXRSS motors on channels 5 and 6

iocshCmd("SmartCreateController(S5,L5,1,500,1000)") 

iocshCmd("SmartCreateController(S6,L6,1,500,1000)") 

## Load SXRSS database
dbLoadRecords("db/sxrss.db", "seg=9")
