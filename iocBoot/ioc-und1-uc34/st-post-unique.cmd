# Unique boot items, after iocInit, for USEG:UND1:3450

#Bypass motor interlock, no rotary pots calibrated.
dbpf("USEG:UND1:3450:CM1MTNOVRRDC","1")
dbpf("USEG:UND1:3450:CM2MTNOVRRDC","1")

dbpf("USEG:UND1:3450:CM1MOTOR.SPMG","3")
dbpf("USEG:UND1:3450:CM2MOTOR.SPMG","3")
