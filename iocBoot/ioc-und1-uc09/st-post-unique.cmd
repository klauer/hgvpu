# No unique boot items, after iocInit, for USEG:UND1:950
# Turn M2 motor off after each move
seq( &autoOff, "MOTOR_DEV=MIRR:UND1:964:X")
# Turn M3 motor off after each move
seq( &autoOff, "MOTOR_DEV=MIRR:UND1:966:X")
