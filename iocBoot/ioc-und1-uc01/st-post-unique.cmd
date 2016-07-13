# No unique boot items, after iocInit, for USEG:UND1:150
dbpf("USEG:UND1:150:ASYNCAM4.AOUT","ZS")

dbpf("USEG:UND1:150:MaximumTaper.VAL","4000")
dbpf("USEG:UND1:150:MaximumSymm.VAL","4000")
dbpf("USEG:UND1:150:MaxSymmetry.VAL","0.08")

dbpf("USEG:UND1:150:CalcFPGAEncOff.VAL","1")

dbpf("USEG:UND1:150:MotorStopPwr.VAL","1")

dbpf("USEG:UND1:150:MotorsError.TPRO","1")
dbpf("USEG:UND1:150:EncoderError.TPRO","1")
dbpf("USEG:UND1:150:DeviceError.TPRO","1")
dbpf("USEG:UND1:150:DeviceStall.TPRO","1")
#dbpf("USEG:UND1:150:ProcessToMove.TPRO","1")
dbpf("USEG:UND1:150:CalibratMotors.TPRO","1")
dbpf("USEG:UND1:150:ResetActiveDead.TPRO","1")
dbpf("USEG:UND1:150:DeviceRecoverd.TPRO","1")
dbpf("USEG:UND1:150:DeviceStart.TPRO","1")
dbpf("USEG:UND1:150:DeviceStop.TPRO","1")

dbpf("USEG:UND1:150:RepeatStop.TPRO","1")
dbpf("USEG:UND1:150:RepeatStop.DISA","1")

