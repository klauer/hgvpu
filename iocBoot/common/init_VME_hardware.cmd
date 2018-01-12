
# Set verbosity level
bspExtVerbosity=0
# ========================================================================
# Initialize Acromag IPAC carriers 
# -------------------------------------------------------------------------
# ipacAddXy9660(const char *cardParamteres)
#   cardParamters: "cardAddr, interruptLvl <slot=memSize,memAddr> <...>"
#       cardAddr - VME A16 address space, must match address jumper settings on carrier board [hex]
#   interruplLvl - VME interrupt level to be used for this carrier (0-7, 0=interrupts disabled)
#           slot - slot letter <A-D>
#        memSize - size of allocated memory [1/2/4/8] in MegaBytes
#        memAddr - memory address of the module, A24 base [hex]
# -------------------------------------------------------------------------

# This is used for the Acromag FPGA DIO module IP-EP201
# It is located on the second IPAC carrier card
# The FPGA DIO module is in the B slot and the SOPC base address 
# is 0x800000 for the FPGA to put it in MEM address space
ipacAddXy9660("0x6000,3 B=1,800000 C=1,A00000")
hgvpuCarrier = ipacAddCarrierType()

ipacAddXy9660("0x0,1 A=1,D00000")
camCarrier = ipacLatestCarrier()

# ========================================================================
# Initialize IP330 ADC
# -------------------------------------------------------------------------
# initIp330(portName,Carrier,Slot,typeString,rangeString,firstChan,lastChan,intVec)
#   portName    - asyn port name
#   Carrier     - IPAC carrier number
#   Slot        - slot on IPAC carrier card
#   typeString  - "D" or "S" for differential or single-ended
#   rangeString - "-5to5","-10to10","0to5", or "0to10"
#                 This value must match hardware setting selected with DIP switches
#   firstChan   - first channel to be digitized.  This must be in the range:
#                 0 to 31 (single-ended)
#                 0 to 15 (differential)
#   lastChan    - last channel to be digitized
#   maxClients  - Maximum number of Ip330 tasks which will attach to this Ip330 module. 
#                 For example Ip330Scan, Ip330Sweep, etc.  This does not refer to the 
#                 number of EPICS clients.  A value of 10 should certainly be safe.
#   intVec      - Interrupt vector
# -------------------------------------------------------------------------
camCarrier && initIp330("ai1",camCarrier,2,"S","0to5",0,31,192)

# ========================================================================
# Configure IP330 ADC
# -------------------------------------------------------------------------
#  portName,scanMode,triggerString,microSecondsPerScan,secondsBetweenCalibrate
#        scanMode = scan mode:
#               0 = disable
#               1 = uniformContinuous
#               2 = uniformSingle
#               3 = burstContinuous (normally recommended)
#               4 = burstSingle
#               5 = convertOnExternalTriggerOnly
# -------------------------------------------------------------------------
camCarrier && configIp330("ai1",1,"Input",1000,0)

# ========================================================================
# Initialize IP-OPTOIO-8
# initIpUnidig(const char *portName, int carrier, int slot, int msecPoll, 
#              int intVec, int risingMask,int fallingMask)
#   portName    - asyn port name
#   carrier     - IPAC carrier card  number
#   slot        - slot on IPAC carrier card
#   msecPoll    - polling time for input bits, if 0 = default to 100 msec
#   intVec      - [optional] VME interrupt vector 
#   risingMask  - [optional] mask of bits to generate interrupts on low to high (24 bits) 
#   fallingMask - [optional] mask of bits to generate interrupts on high to low (24 bits)
# -------------------------------------------------------------------------
camCarrier && initIpUnidig("io8",camCarrier,1,0)

# ========================================================================
# Allocate the number of tyGSOctal modules to support.
# -------------------------------------------------------------------------
# tyGSOctalDrv(maxModules), where  maxModules is the maximum number of modules to support.
camCarrier && tyGSOctalDrv(1)

# ========================================================================
# Initialize octal UART (all channels)
# -------------------------------------------------------------------------
# tyGSOctalModuleInit(char *moduleID, char *ModuleType, int irq_num, char *carrier#, int slot#)
#   moduleID   - assign the IP module a name for future reference. 
#   ModuleType - "RS232", "RS422", or "RS485".
#   irq_num    - interrupt request number/vector.
#   carrier#   - carrier# assigned from the ipacAddCarrierType() call.
#   slot#      - slot number on carrier; slot[A,B,C,D] -> slot#[0,1,2,3].
# -------------------------------------------------------------------------
camCarrier && tyGSOctalModuleInit("MOD0","RS232", 196, camCarrier, 0)

# ========================================================================
#  Create tty devices.
# -------------------------------------------------------------------------
# tyGSOctalDevCreate(char *portname, int moduleID, int port#, int rdBufSize, int wrtBufSize)
#   portname   - assign the port a name for future reference.
#   moduleID   - moduleID from the tyGSOctalModuleInit() call.
#   port#      - port number for this module [0-7].
#   rdBufSize  - read buffer size, in bytes.
#   wrtBufSize - write buffer size, in bytes.
# -----------------------------------------------------------------------
camCarrier && tyGSOctalDevCreate("/tyGS:0:","MOD0",-1,1000,1000)

# ========================================================================
# Initialize CAM Animatics Smart Motors 
# -------------------------------------------------------------------------
camCarrier && cexpsh("iocBoot/common/init_camMotors")

# ========================================================================
# Initialize SSI Encoders TIP114 
# -------------------------------------------------------------------------
# initTip114 (const char *portName, ushort_t carrier, ushort_t slot, int intVec)
#   portName - asyn port name
#   carrier  - IPAC carrier card 
#   slot     - slot on IPAC carrier card <0-3>, where 0=A and 3=D
#   intVec   - VME interrupt vector
# -------------------------------------------------------------------------
initTip114("LinEnc", hgvpuCarrier, 3, 0)

# ========================================================================
# Configure  SSI Linear Encoders TIP114
# -------------------------------------------------------------------------
# configTip114 (const char *portName, int channel, int nbits, int clk,
#               const char *gray, const char *parity, int zeroBits)
#   portName - asyn port name
#   channel  - channel on the IPAC card
#   nbits    - number of encoder bits to read
#   clk      - clock period from 1us to 15us, 0 = disables the channel
#   gray     - use G for graz scale binary, otherwise use B for natural
#   parity   - O = odd, E = even, N = no parity
#   zeroBits - 1 = add two clock cycles, 0 = add 1 clock cycle to data readout
# -------------------------------------------------------------------------
# Half-gap Encoder : USA
configTip114("LinEnc",0,32,5,"B","N",0)
# Half-gap Encoder : USW
configTip114("LinEnc",1,32,5,"B","N",0)
# Half-gap Encoder : DSW
configTip114("LinEnc",2,32,5,"B","N",0)
# Half-gap Encoder : DSA
configTip114("LinEnc",3,32,5,"B","N",0)
# PhaseShifter Encoder
configTip114("LinEnc",4,32,5,"B","N",0)
# Full-gap Encoder : Upstream
configTip114("LinEnc",5,27,5,"B","E",0)
# Full-gap Encoder : Downstream
configTip114("LinEnc",6,27,5,"B","E",0)

# ========================================================================
# Allocate the number of IP520 modules to support.
# -------------------------------------------------------------------------
# IP520(maxModules), where  maxModules is the maximum number of modules to support.
# -------------------------------------------------------------------------
IP520Drv(1)

# ========================================================================
# Initialize octal UART (all channels)
# -------------------------------------------------------------------------
# IP520ModuleInit(char *moduleID, char *ModuleType, int irq_num, char *carrier#, int slot#)
#   moduleID   - assign the IP module a name for future reference.
#   ModuleType - "RS232", "RS422", or "RS485".
#   irq_num    - interrupt request number/vector.
#   carrier#   - carrier# assigned from the ipacAddCarrierType() call.
#   slot#      - slot number on carrier; slot[A,B,C,D] -> slot#[0,1,2,3].
# -------------------------------------------------------------------------
IP520ModuleInit("MOD1","RS232", 204, hgvpuCarrier, 2)

# ========================================================================
#  Create tty devices.
# -------------------------------------------------------------------------
# IP520DevCreate(char *portname, int moduleID, int port#, int rdBufSize, int wrtBufSize)
#   portname   - assign the port a name for future reference.
#   moduleID   - moduleID from the tyGSOctalModuleInit() call.
#   port#      - port number for this module [0-7].
#   rdBufSize  - read buffer size, in bytes.
#   wrtBufSize - write buffer size, in bytes.
# -----------------------------------------------------------------------
IP520DevCreate("/IP520:0:","MOD1",-1,1000,1000)

# ========================================================================
# Create Asyn Serial Port
# -------------------------------------------------------------------------
# drvAsynSerialPortConfigure(char *portName,char *ttyName,int priority,int noAutoConnect,int noProcessEosIn)
#   portName      - The portName that is registered with asynGpib.
#   ttyName       - The name of the local serial port (e.g. "/dev/ttyS0").
#   priority      - Priority at which the asyn I/O thread will run. If this is zero or missing,then
#                   epicsThreadPriorityMedium is used.
#   addr          - This argument is ignored since serial devices are configured with multiDevice=0.
#   noAutoConnect - Zero or missing indicates that portThread should automatically connect. Non-zero if
#                   explicit connect command must be issued.
#   noProcessEos  - If 0 then asynInterposeEosConfig is called specifying both processEosIn and processEosOut.
# -------------------------------------------------------------------------

# ========================================================================
# Set Asyn Serial Port Options
# -------------------------------------------------------------------------
# asynSetOption("portName",addr,"key","value")
# The following parameters are for the "key"  "value" pairs
#   baud    - < 9600 | 50 | 75 | ... | 230400 >
#   bits    - < 8 | 7 | 6 | 5 >
#   parity  - < none | even | odd >
#   stop    - < 1 | 2 >
#   clocal  - < Y | N > ( modem control lines [DTR,DSR] used=Y or ignored=N )
#   crtscts - < N | Y > ( hardware handshake lines [RTS,CTS] used[Y] or ignored[N] )
# -------------------------------------------------------------------------

# Create serial port for Animatics Smart Motor - US Wall ID motor
drvAsynSerialPortConfigure("L7","/IP520:0:1",0,0,0)
# Configure serial port parameters
asynSetOption("L7", -1, "baud", "9600")
asynSetOption("L7", -1, "bits", "8")
asynSetOption("L7", -1, "parity", "none")
asynSetOption("L7", -1, "stop", "1")
asynSetOption("L7", -1, "clocal", "Y")
asynSetOption("L7", -1, "crtscts", "N")

# For Debugging uncomment the following:
#asynSetTraceIOMask("L7", -1, 2)
#asynSetTraceMask("L7", -1, 0x1)

# ========================================================================
# Setup/Configure SmartMotor parameters
# -------------------------------------------------------------------------
# SmartCreateController(motorPortName,asynPortName,realAxis,virtualAxis,movingPollPeriode,idlePollPeriode)
#   motorPortName     - motor moduel port name
#   asynPortName      - asyn port name for serial communication
#   realAxis          - number of real axis
#   virtualAxis       - number of virtual axis
#   movingPollPeriode - poll periode while in motion
#   idlePollPeriode   - poll periode while idle
# -------------------------------------------------------------------------

# Undulator motors
iocshCmd("SmartCreateController(S7,L7,4,1,100,1000)")

# ========================================================================
# Initialize the FPGA
# -------------------------------------------------------------------------
# initIP_EP200_FPGA(ushort carrier, ushort slot, char *filename)
#   Write content to the FPGA. This command will fail if the FPGA already
#   has content loaded, as it will after a soft reboot. To load new FPGA
#   content, you must power cycle the ioc.
#
#  carrier  - IPAC carrier card number
#  slot     - slot on IPAC carrier card
#  filename - Name of the FPGA-content hex file to load into the FPGA
# -------------------------------------------------------------------------
initIP_EP200_FPGA(hgvpuCarrier, 1, "ucmApp/Db/undulator/HGVPU_SSI_SLACLatched_v2.hexout")


# ========================================================================
# Initialize basic field I/O 
# -------------------------------------------------------------------------
# initIP_EP200(ushort carrier, ushort slot, char *portName1, char *portName2,
#              char *portName3, int sopcBase)
#   carrier   - IPAC carrier number
#   slot      - slot on IPAC carrier card
#   portName1 - Name of asyn port for component at sopcBase
#   portName2 - Name of asyn port for component at sopcBase+0x10
#   portName3 - Name of asyn port for component at sopcBase+0x20
#   sopcBase  - must agree with FPGA content (0x800000)
# -------------------------------------------------------------------------
initIP_EP200(hgvpuCarrier, 1, "limits", "monitors", "idmon", 0x800000)

# ========================================================================
# Initialize field-I/O interrupt support
# -------------------------------------------------------------------------
# initIP_EP200_Int(ushort carrier, ushort slot, int intVectorBase, int risingMaskMS,
#                  int risingMaskLS, int fallingMaskMS, int fallingMaskLS)
#   carrier       - IP-carrier number (numbering begins at 0)
#   slot          - IP-slot number (numbering begins at 0)
#   intVectorBase - must agree with the FPGA content loaded (0x90 for softGlue
#                   2.1 and higher; 0x80 for softGlue 2.0 and lower). softGlue
#                   uses three vectors, for example, 0x90, 0x91, 0x92.
#   risingMaskMS  - interrupt on 0->1 for I/O pins 33-48
#   risingMaskLS  - interrupt on 0->1 for I/O pins 1-32
#   fallingMaskMS - interrupt on 1->0 for I/O pins 33-48
#   fallingMaskLS - interrupt on 1->0 for I/O pins 1-32
# -------------------------------------------------------------------------
initIP_EP200_Int(hgvpuCarrier, 1, 0x90, 0x0, 0x0, 0x0, 0x0)

# ========================================================================
# Set field-I/O data direction
# -------------------------------------------------------------------------
# initIP_EP200_IO(ushort carrier, ushort slot, ushort moduleType, ushort dataDir)
#   carrier    - IPAC carrier card number
#   slot       - slot on IPAC carrier card
#   moduleType - one of [201, 202, 203, 204]
#   dataDir    - Bit mask, in which only the first 9 bits are significant.  The
#                meaning of each bit depends on moduleType, as shown in the
#                table below.  If a bit is set, the corresponding field I/O pins
#                are outputs.  Note that for the 202 and 204 modules, all I/O
#                is differential, and I/O pin N is paired with pin N+1.  For the
#                203 module, pins 25/26 through 47/48 are differential pairs.
#
#    -------------------------------------------------------------------
#    |  Correspondence between dataDir bits (0-8) and I/O pins (1-48)  |
#    -------------------------------------------------------------------
#    |             |  201          |  202/204           |  203         | 
#    -------------------------------------------------------------------
#    | bit 0       |  pins 1-8     |  pins 1, 3,25,27   |  pins 25,27  | 
#    | bit 1       |  pins 9-16    |  pins 5, 7,29,31   |  pins 29,31  | 
#    | bit 2       |  pins 17-24   |  pins 9,11,33,35   |  pins 33,35  | 
#    | bit 3       |  pins 25-32   |  pins 13,15,37,39  |  pins 37,39  | 
#    |             |               |                    |              |
#    | bit 4       |  pins 33-40   |  pins 17,19,41,43  |  pins 41,43  | 
#    | bit 5       |  pins 41-48   |  pins 21,23,45,47  |  pins 45,47  | 
#    | bit 6       |         x     |            x       |  pins 1-8    | 
#    | bit 7       |         x     |            x       |  pins 9-16   | 
#    |             |               |                    |              |
#    | bit 8       |         x     |            x       |  pins 17-24  | 
#    -------------------------------------------------------------------
#    Examples:
#    1. For the IP-EP201, moduleType is 201, and dataDir == 0x3c would mean
#       that I/O bits 17-48 are outputs.
#    2. For the IP-EP202 (IP-EP204), moduleType is 202(204), and dataDir == 0x13
#       would mean that I/O bits 1,3,25,27, 5,7,29,31, 17,19,41,43 are outputs.
#    3. For the IP-EP203, moduleType is 203, and dataDir == 0x??? would mean
#       that I/O bits 1-8, 25,27, 29,31, 33,35, 45,47 are outputs.
# -------------------------------------------------------------------------
initIP_EP200_IO(hgvpuCarrier, 1, 201, 0x12)

# ========================================================================
# Initialize softGlue signal-name support
# -------------------------------------------------------------------------
#    All instances of a single-register component are initialized with a single
#    call, as follows:
# initIP_EP201SingleRegisterPort(char *portName, ushort carrier, ushort slot)
#   portName - asyn port name
#   carrier  - IPAC carrier card number
#   slot     - slot on IPAC carrier card
# -------------------------------------------------------------------------

# Init all FPGA SOPC PIO single register ports
# internalIO - Various monitors (currently only limit lockout)
initIP_EP201SingleRegisterPort("internalIO", hgvpuCarrier, 1)
# internalIO1 - Lower 16 bits US wall linear encoder value + offset
initIP_EP201SingleRegisterPort("internalIO1", hgvpuCarrier, 1)
# internalIO2 - Upper 16 bits US wall linear encoder value + offset
initIP_EP201SingleRegisterPort("internalIO2", hgvpuCarrier, 1)
# internalIO3 - Lower 16 bits US aisle linear encoder value + offset
initIP_EP201SingleRegisterPort("internalIO3", hgvpuCarrier, 1)
# internalIO4 - Upper 16 bits US aisle linear encoder value + offset
initIP_EP201SingleRegisterPort("internalIO4", hgvpuCarrier, 1)
# internalIO5 - Lower 16 bits DS wall linear encoder value + offset
initIP_EP201SingleRegisterPort("internalIO5", hgvpuCarrier, 1)
# internalIO6 - Upper 16 bits DS wall linear encoder value + offset
initIP_EP201SingleRegisterPort("internalIO6", hgvpuCarrier, 1)
# internalIO7 - Lower 16 bits DS aisle linear encoder value + offset
initIP_EP201SingleRegisterPort("internalIO7", hgvpuCarrier, 1)
# internalIO8 - Upper 16 bits DS aisle linear encoder value + offset
initIP_EP201SingleRegisterPort("internalIO8", hgvpuCarrier, 1)
# internalIO9 - US wall linear encoder offset (16-bits)
initIP_EP201SingleRegisterPort("internalIO9", hgvpuCarrier, 1)
# internalIO10 - DS aisle linear encoder offset (16-bits)
initIP_EP201SingleRegisterPort("internalIO10", hgvpuCarrier, 1)
# internalIO11 - US aisle linear encoder offset (16-bits)
initIP_EP201SingleRegisterPort("internalIO11", hgvpuCarrier, 1)
# internalIO12 - DS wall linear encoder offset (16-bits)
initIP_EP201SingleRegisterPort("internalIO12", hgvpuCarrier, 1)
# internalIO13 - ID Maximum symmetry allowed (16-bits)
initIP_EP201SingleRegisterPort("internalIO13", hgvpuCarrier, 1)
# internalIO14 - ID Maximum taper allowed (16-bits)
initIP_EP201SingleRegisterPort("internalIO14", hgvpuCarrier, 1)

# PIO 16 - DSA Raw Encoder Counts (Low 16-bits)
initIP_EP201SingleRegisterPort("pio16", hgvpuCarrier, 1)
# PIO 17 - DSA Raw Encoder Counts (High 16-bits)
initIP_EP201SingleRegisterPort("pio17", hgvpuCarrier, 1)

# PIO 18 - DSW Raw Encoder Counts (Low 16-bits)
initIP_EP201SingleRegisterPort("pio18", hgvpuCarrier, 1)
# PIO 19 - DSW Raw Encoder Counts (High 16-bits)
initIP_EP201SingleRegisterPort("pio19", hgvpuCarrier, 1)

# PIO 20 - USA Raw Encoder Counts (Low 16-bits)
initIP_EP201SingleRegisterPort("pio20", hgvpuCarrier, 1)
# PIO 21 - USA Raw Encoder Counts (High 16-bits)
initIP_EP201SingleRegisterPort("pio21", hgvpuCarrier, 1)

# PIO 22 - DSW Raw Encoder Counts (Low 16-bits)
initIP_EP201SingleRegisterPort("pio22", hgvpuCarrier, 1)
# PIO 23 - DSW Raw Encoder Counts (High 16-bits)
initIP_EP201SingleRegisterPort("pio23", hgvpuCarrier, 1)

# PIO 24 - ID Errors (High 16-bits)
initIP_EP201SingleRegisterPort("pio24", hgvpuCarrier, 1)

# PIO 25 - US Symmetry Encoder Difference Raw Low (High 16-bits)
initIP_EP201SingleRegisterPort("pio25", hgvpuCarrier, 1)
# PIO 26 - US Symmetry Encoder Difference Raw High (High 16-bits)
initIP_EP201SingleRegisterPort("pio26", hgvpuCarrier, 1)
# PIO 27 - DS Symmetry Encoder Difference Raw Low (High 16-bits)
initIP_EP201SingleRegisterPort("pio27", hgvpuCarrier, 1)
# PIO 28 - DS Symmetry Encoder Difference Raw High (High 16-bits)
initIP_EP201SingleRegisterPort("pio28", hgvpuCarrier, 1)

