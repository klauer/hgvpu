# dbpf("USEG:TST1:150:Device.VAL","Long Term Test Stand")
dbpf("USEG:TST1:150:Device.VAL","Floating Test Stand (CMM)")

dbpf("USEG:TST1:150:MaximumTaper.VAL","4000")
dbpf("USEG:TST1:150:MaximumSymm.VAL","4000")
dbpf("USEG:TST1:150:MaxSymmetry.VAL","0.08")

dbpf("USEG:TST1:150:CalcFPGAEncOff.VAL","1")

#! # 20180205-KL: Original offsets from b081-mc01
#! # FPGA encoder offsets 
#! dbpf("USEG:TST1:150:USWLinEncOffset.VAL","5335")
#! dbpf("USEG:TST1:150:USALinEncOffset.VAL","23273")
#! dbpf("USEG:TST1:150:DSWLinEncOffset.VAL","0")
#! dbpf("USEG:TST1:150:DSALinEncOffset.VAL","9564")
#! 
#! # SSI encoder offsets
#! dbpf("USEG:TST1:150:USWLinearEncoder.AOFF","99.7326")
#! dbpf("USEG:TST1:150:USALinearEncoder.AOFF","97.9387")
#! dbpf("USEG:TST1:150:DSWLinearEncoder.AOFF","100.2661")
#! dbpf("USEG:TST1:150:DSALinearEncoder.AOFF","99.3098")


#!# 20180205-KL: HGVPU SN001 (HXU001 offsets)
#!#FPGA
#!dbpf("USEG:TST1:150:USWLinEncOffset.VAL","0")
#!dbpf("USEG:TST1:150:USALinEncOffset.VAL","1338")
#!dbpf("USEG:TST1:150:DSWLinEncOffset.VAL","11389")
#!dbpf("USEG:TST1:150:DSALinEncOffset.VAL","12506")
#!
#!#DEVICE SETUP
#!dbpf("USEG:TST1:150:USWLinearEncoder.AOFF","89.2202")
#!dbpf("USEG:TST1:150:USALinearEncoder.AOFF","89.0865")
#!dbpf("USEG:TST1:150:DSWLinearEncoder.AOFF","88.0813")
#!dbpf("USEG:TST1:150:DSALinearEncoder.AOFF","87.9695")


dbpf("USEG:TST1:150:MotorsError.TPRO","1")
dbpf("USEG:TST1:150:EncoderError.TPRO","1")
dbpf("USEG:TST1:150:DeviceError.TPRO","1")
dbpf("USEG:TST1:150:DeviceStall.TPRO","1")
#dbpf("USEG:TST1:150:ProcessToMove.TPRO","1")
dbpf("USEG:TST1:150:CalibratMotors.TPRO","1")
dbpf("USEG:TST1:150:ResetActiveDead.TPRO","1")
dbpf("USEG:TST1:150:DeviceRecoverd.TPRO","1")
dbpf("USEG:TST1:150:DeviceStart.TPRO","1")
dbpf("USEG:TST1:150:DeviceStop.TPRO","1")

dbpf("USEG:TST1:150:RepeatStop.TPRO","1")
dbpf("USEG:TST1:150:RepeatStop.DISA","1")

dbpf("USEG:TST1:150:GapMotor.VELO","0.5")
dbpf("USEG:TST1:150:GapMotor.VAL","100")

dbpf("USEG:TST1:150:ASYNHGU.AOUT","BRKENG:0")
dbpf("USEG:TST1:150:ASYNHGU.AOUT","ZS:0")

dbpf("USEG:TST1:150:MotorStopPwr.VAL","0")
dbpf("USEG:TST1:150:FPGAIntlckLatch.VAL","0")
dbpf("USEG:TST1:150:FPGAIntlckLatch.VAL","1")
dbpf("USEG:TST1:150:FPGAIntlckLatch.VAL","0")
dbpf("USEG:TST1:150:MotorStopPwr.VAL","1")

# Test to disable motor trigger when device is not active:
dbpf("USEG:TST1:150:GapMotor:Defer.SDIS","USEG:TST1:150:DeviceActive")
dbpf("USEG:TST1:150:GapMotor:Defer.DISV","0")
dbpf("USEG:TST1:150:GapMotor:Trig.SDIS","USEG:TST1:150:DeviceActive")
dbpf("USEG:TST1:150:GapMotor:Trig.DISV","0")

