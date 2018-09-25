dbpf("USEG:LTTS:350:DebugLevel","Debug ON")

dbpf("USEG:LTTS:350:Device.VAL","Long Term Test Stand")
# dbpf("USEG:LTTS:350:Device.VAL","Floating Test Stand (CMM)")

dbpf("USEG:LTTS:350:MaximumTaper.VAL","4000")
dbpf("USEG:LTTS:350:MaximumSymm.VAL","4000")
dbpf("USEG:LTTS:350:MaxSymmetry.VAL","0.08")

dbpf("USEG:LTTS:350:CalcFPGAEncOff.VAL","1")
dbpf("USEG:LTTS:350:MotorsErrorSQ.TPRO","1")
dbpf("USEG:LTTS:350:EncoderErrorSQ.TPRO","1")
dbpf("USEG:LTTS:350:DeviceErrorSQ.TPRO","2")
dbpf("USEG:LTTS:350:DeviceStallSQ.TPRO","1")
#dbpf("USEG:LTTS:350:ProcessToMove.TPRO","1")
dbpf("USEG:LTTS:350:CalibrateMotors.TPRO","1")
#dbpf("USEG:LTTS:350:ResetActiveDead.TPRO","1")
dbpf("USEG:LTTS:350:DeviceRecovered.TPRO","1")

dbpf("USEG:LTTS:350:M1_ASYN.AOUT","BRKENG:0")
dbpf("USEG:LTTS:350:M1_ASYN.AOUT","ZS:0")

dbpf("USEG:LTTS:350:MotorStopPwr.VAL","0")
dbpf("USEG:LTTS:350:FPGAIntlckLatch.VAL","0")
dbpf("USEG:LTTS:350:FPGAIntlckLatch.VAL","1")
dbpf("USEG:LTTS:350:FPGAIntlckLatch.VAL","0")
dbpf("USEG:LTTS:350:MotorStopPwr.VAL","1")

# Test for disabeling Stall error at bootup
dbpf("USEG:LTTS:350:CalibrateMotors.PROC","1")
dbpf("USEG:LTTS:350:USWStallCheck.PROC","1")
dbpf("USEG:LTTS:350:DSWStallCheck.PROC","1")
dbpf("USEG:LTTS:350:USAStallCheck.PROC","1")
dbpf("USEG:LTTS:350:DSAStallCheck.PROC","1")
dbpf("USEG:LTTS:350:USWStallCheck.PROC","1")
dbpf("USEG:LTTS:350:DSWStallCheck.PROC","1")
dbpf("USEG:LTTS:350:USAStallCheck.PROC","1")
dbpf("USEG:LTTS:350:DSAStallCheck.PROC","1")

# Disable checking of FullGapEncoders on LTTS
dbpf("USEG:LTTS:350:EncoderCheck.DISA","1")
dbpf("USEG:LTTS:350:USGapLinearEncCheck.VAL","0")
dbpf("USEG:LTTS:350:DSGapLinearEncCheck.VAL","0")
dbpf("USEG:LTTS:350:USGapLinearEncCheck.DISA","1")
dbpf("USEG:LTTS:350:DSGapLinearEncCheck.DISA","1")
dbpf("USEG:LTTS:350:EncoderCheck.DISA","0")

# Enable Simulation on boot and reduce number of retries
dbpf("USEG:LTTS:350:MaxRetries","8")
