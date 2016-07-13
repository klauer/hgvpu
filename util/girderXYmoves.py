#!/usr/bin/env python
import threading
import numpy as np

from pcaspy import Driver, SimpleServer
from epics import caget, caput
import girderGeometry as gird

CAM_ANGLE_DEG = []
CAM_ANGLE_RAD = []
US_RBK = []
DS_RBK = []
ROLL_RBK = 0

waitTime = 0.5

PV_PREFIX = 'USEG:UND1:150:'
CAM_PVS = ['CM1', 'CM2', 'CM3', 'CM4', 'CM5']
PV_CALL_PREFIX = PV_PREFIX + '%(cam)s%(suffix)s'

# PVs available when PCASpy program is running
PY_DB = {
    'D_X': {'prec': 4, 'unit': 'mm'},
    'D_Y': {'prec': 4, 'unit': 'mm'},
    'D_ROLL': {'prec': 4, 'unit': 'rad'},
    'D_PITCH': {'prec': 4, 'unit': 'rad'},
    'D_YAW': {'prec': 4, 'unit': 'rad'},
    'US_X_ACT': {'prec': 4, 'unit': 'mm'},
    'US_Y_ACT': {'prec': 4, 'unit': 'mm'},
    'DS_X_ACT': {'prec': 4, 'unit': 'mm'},
    'DS_Y_ACT': {'prec': 4, 'unit': 'mm'},
    'GIRD_ROLL': {'prec': 4},
    'GIRD_MOVE': {'type': 'enum', 'enums': ['WAIT', 'GO'], 'value': 0},
    'GIRD_MOVE_ERR': {'type': 'enum', 'enums': ['OK', 'ERROR'], 'value': 0}
}


##################################################################################
# Read CAM positions form PVs and store in global variables
def read_cam_positions():
    global CAM_ANGLE_DEG
    global CAM_ANGLE_RAD
#    CAM_ANGLE_DEG = [caget(PV_CALL_PREFIX % {"cam": cam, "suffix": "MOTOR.RBV"}) for cam in CAM_PVS]
    CAM_ANGLE_DEG = [caget(PV_CALL_PREFIX % {"cam": cam, "suffix": "READDEG"}) for cam in CAM_PVS]
    CAM_ANGLE_RAD = map(lambda value: value * np.pi/180, CAM_ANGLE_DEG)


#################################################################################
# Convert incremental changes into absolute values
def delta_to_abs_pos(d_x, d_y, d_pitch, d_roll, d_yaw):
    global US_RBK
    global DS_RBK
    global ROLL_RBK
    max_val = 1.0
    us_z = gird.geometry["z3"]
    ds_z = gird.geometry["z2"]
    us_x = US_RBK[0] + d_x + us_z*np.sin(d_yaw)
    us_y = US_RBK[1] + d_y + us_z*np.sin(d_pitch)
    ds_x = DS_RBK[0] + d_x + ds_z*np.sin(d_yaw)
    ds_y = DS_RBK[1] + d_y + ds_z*np.sin(d_pitch)
    roll = ROLL_RBK + d_roll

    if max((abs(x) for x in [us_x, us_y, ds_x, ds_y])) > max_val:
        raise ValueError("Motion request would required some girder to move outside of +/- 1.0 mm range.")
    return [us_x, us_y, us_z], [ds_x, ds_y, ds_z], roll


##################################################################################
# Convert motor angles of girder 3 axis side into X/Y + roll position
# this function is based on function camMove3 in girderAngle2Axis.m
def cam_move3():
    m3inv = np.array(gird.geometry["m3inv"])
    p = m3inv.dot(np.array([gird.geometry["e1"]*np.sin(CAM_ANGLE_RAD[0]),
                            gird.geometry["e2"]*np.sin(CAM_ANGLE_RAD[1]),
                            gird.geometry["e3"]*np.sin(CAM_ANGLE_RAD[2])]))
    return p[0:2], p[2]


# Convert motor angles of girder 2 axis side into X/Y position
# this function is based on function camMove2 in girderAngle2Axis.m
def cam_move2(roll):
    variables = ["m2inv", "cp4", "cp5", "u4", "u5", "e4", "e5"]
    v = dict(map(lambda x: (x, np.array(gird.geometry[x])), variables))
    zzo = np.array([0, 0, 1])
    val_1 = v["e4"] * np.sin(CAM_ANGLE_RAD[3]) - roll * v["u4"].dot(np.cross(zzo, v["cp4"].T))
    val_2 = v["e5"] * np.sin(CAM_ANGLE_RAD[4]) - roll * v["u5"].dot(np.cross(zzo, v["cp5"].T))
    return v["m2inv"].dot(np.array([val_1, val_2]))


# Convert angles into upstream and downstream positions
# this function is based on function girderAngle2Axis in girderAngle2Axis.m
def angle2axis(z_us, z_ds):
    global CAM_ANGLE_RAD
    p3, roll = cam_move3()
    p2 = cam_move2(roll)
    z3 = gird.geometry["z3"]
    z2 = gird.geometry["z2"]
    p_us = p3 + ((z_us - z3) / (z2 - z3)) * (p2 - p3)
    p_us = np.append(p_us, z_us)
    p_ds = p3 + ((z_ds - z3) / (z2 - z3)) * (p2 - p3)
    p_ds = np.append(p_ds, z_ds)
    return p_us, p_ds, roll


# Read motor angle position and start conversion to X/Y position
# this function is based on function girderAxisFromCamAngles in girderAxisFromCamAngles.m
def gird_axis_from_cam_angle():
    global US_RBK
    global DS_RBK
    global ROLL_RBK
    read_cam_positions()
    US_RBK, DS_RBK, ROLL_RBK = angle2axis(gird.geometry["z3"], gird.geometry["z2"])


##################################################################################
# Set CAM motors to angles defined in input parameter
def set_cam_angles(cam_angles):
    # push cam value to motor PVs to execute the move
    for index, cam in enumerate(CAM_PVS):
        caput(PV_CALL_PREFIX % {"cam": cam, "suffix": "MOTOR"}, cam_angles[index])


# Convert desired axis position into cam angles
# this function is based on function girderAxis2Angle in girderAxis2Angle.m
def gird_pos_to_cam_angle(us_p, ds_p, roll):
    variables = ["e1", "e2", "e3", "e4", "e5", "z2", "z3", "m2", "m3"]
    v = dict(map(lambda x: (x, gird.geometry[x]), variables))
    v["m2"] = np.array(v["m2"])
    v["m3"] = np.array(v["m3"])
    us_pa = np.array(us_p)
    ds_pa = np.array(ds_p)
    dp = ds_pa - us_pa
    factor2 = (v["z2"] - us_pa[2]) / (ds_pa[2] - us_pa[2])
    factor3 = (v["z3"] - us_pa[2]) / (ds_pa[2] - us_pa[2])
    p2 = us_pa + factor2 * dp
    p3 = us_pa + factor3 * dp
    p3_a = np.array([p3[0], p3[1], roll])
    p2_a = np.array([p2[0], p2[1], roll])
    phi_term3 = v["m3"].dot(p3_a)
    phi_term2 = v["m2"].dot(p2_a)
    cam1 = np.arcsin(phi_term3[0]/v["e1"])
    cam2 = np.arcsin(phi_term3[1]/v["e2"])
    cam3 = np.arcsin(phi_term3[2]/v["e3"])
    cam4 = np.arcsin(phi_term2[0]/v["e4"])
    cam5 = np.arcsin(phi_term2[1]/v["e5"])
    
    # valid calculated positions are in the range +90 to -90 degrees
    angle_limit = np.pi/2
    max_angle = max((abs(x) for x in [cam1, cam2, cam3, cam4, cam5]))
    nan_angle = np.any(np.isnan([cam1, cam2, cam3, cam4, cam5]))
    print "angle max: ", max_angle, ", angle is nan: ", nan_angle
    if max_angle > angle_limit or nan_angle:
        raise ValueError("Motion request calculated an invalid position")
    
    return cam1, cam2, cam3, cam4, cam5


##################################################################################
# Main class for PCAspy application
class UndGirdXYMovDriver(Driver):
    def __init__(self):
        Driver.__init__(self)
        self.eid = threading.Event()
        self.tid = threading.Thread(target=self.wait_task)
        self.tid.setDaemon(True)
        self.tid.start()

    # Main task that reads position and
    def wait_task(self):
        while True:
            self.eid.wait(waitTime)
            # Read girder position
            gird_axis_from_cam_angle()
            # Publish girder positions to PVs
            self.setParam('US_X_ACT', US_RBK[0])
            self.setParam('US_Y_ACT', US_RBK[1])
            self.setParam('DS_X_ACT', DS_RBK[0])
            self.setParam('DS_Y_ACT', DS_RBK[1])
            self.setParam('GIRD_ROLL', ROLL_RBK)
            self.updatePVs()
            # Read girder move command status and
            # execute move when triggered
            if self.getParam('GIRD_MOVE'):
                # Clear GIRDER MOVE and ERROR PVs
                self.setParam('GIRD_MOVE', 0)
                self.setParam('GIRD_MOVE_ERR', 0)
                print "\nProcessing girder move command"
                # Read parameters form PVs
                d_x = self.getParam('D_X')
                d_y = self.getParam('D_Y')
                d_pitch = self.getParam('D_PITCH')
                d_roll = self.getParam('D_ROLL')
                d_yaw = self.getParam('D_YAW')
                try:
                    # Covert delta values into an absolute position
                    us_des, ds_des, roll_des = delta_to_abs_pos(d_x, d_y, d_pitch, d_roll, d_yaw)
                    print "us_rbk", US_RBK, "\nds_rbk", DS_RBK, "\nroll_rbk", ROLL_RBK
                    print "us_des", us_des, "\nds_des", ds_des, "\nroll_des", roll_des
                    print "us_diff", US_RBK-us_des, "\nds_diff", DS_RBK-ds_des, "\nroll_diff", ROLL_RBK-roll_des
                    # Calculate a new cam position
                    cam_rad = gird_pos_to_cam_angle(us_des, ds_des, roll_des)
                    cam_deg = map(lambda value: value * 180/np.pi, cam_rad)
                    print "desired positions\nin radians:", cam_rad, "\nin degrees", cam_deg, "\n", CAM_ANGLE_DEG
                    print np.floor(CAM_ANGLE_DEG*100000)/100000 - np.floor(cam_deg*100000)/100000,
                    # Write the value to the motors and start the move
                    set_cam_angles(cam_deg)
                except ValueError, e:
                    print e
                    self.setParam('GIRD_MOVE_ERR', 1)

            self.updatePVs()

if __name__ == '__main__':
    server = SimpleServer()
    server.createPV(PV_PREFIX, PY_DB)
    driver = UndGirdXYMovDriver()

    # process CA transactions
    while True:
        server.process(0.1)
