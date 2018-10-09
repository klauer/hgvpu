# Turn Sequence debugging ON
dbpf("USEG:MMF:HXR1:DebugLevel","Debug ON")

# Set device name
dbpf("USEG:MMF:HXR1:Device.VAL","HXR SN-001 from MoSo")

# Set error thresholds for Taper, Symmetry
dbpf("USEG:MMF:HXR1:MaximumTaper.VAL","1000")
dbpf("USEG:MMF:HXR1:MaximumSymm.VAL","1000")
dbpf("USEG:MMF:HXR1:MaxSymmetry.VAL","0.08")

# Set record procesing traces
dbpf("USEG:MMF:HXR1:MotorsErrorSQ.TPRO","1")
dbpf("USEG:MMF:HXR1:EncoderErrorSQ.TPRO","1")
dbpf("USEG:MMF:HXR1:DeviceErrorSQ.TPRO","2")
dbpf("USEG:MMF:HXR1:DeviceStallSQ.TPRO","1")
#dbpf("USEG:MMF:HXR1:ProcessToMove.TPRO","1")
dbpf("USEG:MMF:HXR1:CalibrateMotors.TPRO","1")
#dbpf("USEG:MMF:HXR1:ResetActiveDead.TPRO","1")
dbpf("USEG:MMF:HXR1:DeviceRecovered.TPRO","1")

# Clear FPGA latching errors
dbpf("USEG:MMF:HXR1:MotorStopPwr.VAL","0")
dbpf("USEG:MMF:HXR1:FPGAIntlckLatch.VAL","0")
dbpf("USEG:MMF:HXR1:FPGAIntlckLatch.VAL","1")
dbpf("USEG:MMF:HXR1:FPGAIntlckLatch.VAL","0")
dbpf("USEG:MMF:HXR1:MotorStopPwr.VAL","1")

# Engaget the brakes and reset the motor errors
dbpf("USEG:MMF:HXR1:M1_ASYN.AOUT","BRKENG:0")
dbpf("USEG:MMF:HXR1:M1_ASYN.AOUT","ZS:0")
# Reset CAM Motor Error
dbpf("USEG:MMF:HXR1:ASYNCAM4.AOUT","ZS ")

# Reset Stall error at bootup
dbpf("USEG:MMF:HXR1:CalibrateMotors.PROC","1")
dbpf("USEG:MMF:HXR1:USWStallCheck.PROC","1")
dbpf("USEG:MMF:HXR1:DSWStallCheck.PROC","1")
dbpf("USEG:MMF:HXR1:USAStallCheck.PROC","1")
dbpf("USEG:MMF:HXR1:DSAStallCheck.PROC","1")
dbpf("USEG:MMF:HXR1:USWStallCheck.PROC","1")
dbpf("USEG:MMF:HXR1:DSWStallCheck.PROC","1")
dbpf("USEG:MMF:HXR1:USAStallCheck.PROC","1")
dbpf("USEG:MMF:HXR1:DSAStallCheck.PROC","1")

# Increase number of retries 
dbpf("USEG:MMF:HXR1:MaxRetries.VAL","25")

# Disable US Gap Encoder Error Check (temporarily, as it produces fault)
dbpf("USEG:MMF:HXR1:USGapEncoder_Err.INPA","0")
dbpf("USEG:MMF:HXR1:USGapEncoder_Err.A","0")

