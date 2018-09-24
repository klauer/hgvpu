dbpf("USEG:LTTS:350:DebugLevel","Debug ON")

dbpf("USEG:LTTS:350:Device.VAL","Long Term Test Stand")
# dbpf("USEG:LTTS:350:Device.VAL","Floating Test Stand (CMM)")

dbpf("USEG:LTTS:350:MaximumTaper.VAL","4000")
dbpf("USEG:LTTS:350:MaximumSymm.VAL","4000")
dbpf("USEG:LTTS:350:MaxSymmetry.VAL","0.08")

dbpf("USEG:LTTS:350:CalcFPGAEncOff.VAL","1")
dbpf("USEG:LTTS:350:MotorsError.TPRO","1")
dbpf("USEG:LTTS:350:EncoderError.TPRO","1")
dbpf("USEG:LTTS:350:DeviceError.TPRO","1")
dbpf("USEG:LTTS:350:DeviceStall.TPRO","1")
#dbpf("USEG:LTTS:350:ProcessToMove.TPRO","1")
dbpf("USEG:LTTS:350:CalibrateMotors.TPRO","1")
dbpf("USEG:LTTS:350:ResetActiveDead.TPRO","1")
dbpf("USEG:LTTS:350:DeviceRecoverd.TPRO","1")
dbpf("USEG:LTTS:350:DeviceStart.TPRO","1")
dbpf("USEG:LTTS:350:DeviceStop.TPRO","1")

dbpf("USEG:LTTS:350:RepeatStop.TPRO","1")
dbpf("USEG:LTTS:350:RepeatStop.DISA","1")

dbpf("USEG:LTTS:350:GapMotor.VELO","0.5")
dbpf("USEG:LTTS:350:GapMotor.VAL","100")

dbpf("USEG:LTTS:350:M1_ASYN.AOUT","BRKENG:0")
dbpf("USEG:LTTS:350:M1_ASYN.AOUT","ZS:0")

dbpf("USEG:LTTS:350:MotorStopPwr.VAL","0")
dbpf("USEG:LTTS:350:FPGAIntlckLatch.VAL","0")
dbpf("USEG:LTTS:350:FPGAIntlckLatch.VAL","1")
dbpf("USEG:LTTS:350:FPGAIntlckLatch.VAL","0")
dbpf("USEG:LTTS:350:MotorStopPwr.VAL","1")

# Test to disable motor trigger when device is not active:
dbpf("USEG:LTTS:350:GapMotor:Defer.SDIS","USEG:LTTS:350:DeviceActive")
dbpf("USEG:LTTS:350:GapMotor:Defer.DISV","0")
dbpf("USEG:LTTS:350:GapMotor:Trig.SDIS","USEG:LTTS:350:DeviceActive")
dbpf("USEG:LTTS:350:GapMotor:Trig.DISV","0")
