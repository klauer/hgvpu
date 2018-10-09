#!/bin/bash

cd edm
edm -x -eolc -m 'U=USEG:LTTS:350' ID4SSysControl.edl &

# Uncoment for straight access to Asyn Records, otherwise available on main screen
#!edm -x -eolc -m "P=USEG:LTTS:350:,R=M1_ASYN" asynRecord.edl &
#!edm -x -eolc -m "P=USEG:LTTS:350:,R=M2_ASYN" asynRecord.edl &
#!edm -x -eolc -m "P=USEG:LTTS:350:,R=M3_ASYN" asynRecord.edl &
#!edm -x -eolc -m "P=USEG:LTTS:350:,R=M4_ASYN" asynRecord.edl &
