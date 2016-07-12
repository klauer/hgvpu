/*
 * file:                autoOff.st
 * purpose:             DELTA Undulator Motor Off after Move
 * created:             2-Oct-2014
 * property of:         Stanford Linear Accelerator Center
 *
 * revision history:
 *   2-Oct-2014         Mitch DEwart             initial release version
 */
program autoOff 
        option +d; /* debug */
        option -c; /* connect to PVs option */
        option +r; /* reentrant */


/* Internal veriables: */

        int    dmov;           assign dmov to        "{MOTOR_DEV}:MOTOR.DMOV";      monitor dmov;
        int    cnen;           assign cnen to        "{MOTOR_DEV}:MOTOR.CNEN";      monitor cnen;


/**************************************************************************************************************/

ss disable
{
    state s_Stby {
        entry {
            cnen = 0;
            pvPut(cnen);
        }
        when(dmov == 0) {
        } state s_Movn
    }

    state s_Movn {
        when(dmov == 1) {
        } state s_Stby
    }
}
