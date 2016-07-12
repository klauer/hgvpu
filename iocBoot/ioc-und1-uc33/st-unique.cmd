# Add items for DELTA needed before iocInit
# 

## Simulation motor to replace translation stages
## Motor simulation configuration (port, numAxes)
motorSimCreateController("motorSim1", 2)

## motorSimConfigAxis(port, axis, lowLimit, highLimit, home, start)
motorSimConfigAxis("motorSim1", 0, 20000, -20000,  500, 0)
motorSimConfigAxis("motorSim1", 1, 20000, -20000,  500, 0)

dbLoadRecords("db/xxTranslationAsynMotor.vdb", "U=USEG:UND1:3350, M=TM1, MDESC=TM 1,PORT=motorSim1,ADDR=0")
dbLoadRecords("db/xxTranslationAsynMotor.vdb", "U=USEG:UND1:3350, M=TM2, MDESC=TM 2,PORT=motorSim1,ADDR=1")

## Setup/Configure SmartMotor parameters - TRANS #1
## SmartMotorConfig("Card" #, ASYN port)
#SmartMotorConfig(5,"L5")
#iocshCmd("SmartMotorConfig(5,L5)")
iocshCmd("SmartCreateController(S5,L5,1,500,1000)")

## Load DELTA database
dbLoadRecords("db/delta.db", "seg=33")
