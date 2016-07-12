4/23/2008 Smart Monitor Functionality

All of the smart monitors can globally be turned ON or OFF.


A linear translation position descrepency will cause an individual motor into STOP mode.

Changing the translation stage linear potentiometer readback offset; for testing purposes; causes the motor position to match and/or not match the translation stage motor position.  This causes the position error of the smart monitor to turn on or off.

The individual motion control override on a translation stage allows the motor mode to be switched from STOP to GO.  Turning the motion control override off again causes the individual motor to go back into STOP mode.

Correcting the translation stage position error for a motors, allows you to put the motors into GO mode.  This is not done automatically.



A rotary motor position descrepency will cause an individual motor into STOP mode.

Causing a position descrepency for a rotary cam motor causes a position error and puts the individual cam motor into STOP mode.

If any of the cam motors are in STOP mode, trying to move the undulator by setting the upstream/downstream position will not immediately move any motors.  The EPICS database checks if any motors are in STOP mode and will not issue the final go command for a move via the calculations.  Once the STOP mode for the appropriate motor(s) has changed to GO, the undulator will begin to move.  During the time when a cam motor is in STOP mode does not prohibit moving the other cam motors from the cam motors individual control screen.

The individual motion control override on a cam motor allows the motor mode to be switched from STOP to GO.  Turning the motion control override off again causes the individual motor to go back into STOP mode.

Correcting the rotary cam position error allows you to put the motor back into GO mode.  This is not done automatically.



Causing a communication problem (pull cable off) puts an individual Smart Motor into STOP mode.  This takes up to 10 seconds to detect.  Putting motor to GO mode during said time does not get put the motor back to STOP mode for up to 10 seconds.  This is becuase the motors are only checked every 10 seconds for a communication problem.  If the Smart Monitor sequence program changed the scan rate, this behaviour will change.

Plugging the cable back in restores communications, but may not be detected for up to 10 seconds.  Restoring communications will NOT put the motor back into GO mode automatically.
