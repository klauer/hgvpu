#!/bin/bash

#cd $EDM/und/
#export EPICS_CA_ADDR_LIST=134.79.219.118:5064

edm -x -eolc -m "area=und1,x=14,EVGLOC=IN20,subsys=mc,y=6,U=USEG:UND1:150,B=BFW:UND1:110,N=1,USEG=U01,ioc=IOC:UND1:UC01,crat=CRAT:UND1:UC01,UN1=USEG:UND1:250" xxUndulator.edl &

