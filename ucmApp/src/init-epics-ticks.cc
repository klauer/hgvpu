#include <rtems.h>

static rtems_interval ini_ticks();

extern "C" rtems_interval rtemsTicksPerSecond;
extern "C" double         rtemsTicksPerSecond_double;
extern "C" double         rtemsTicksPerTwoSeconds_double;

rtems_interval rtemsTicksPerSecond = ini_ticks();
double         rtemsTicksPerSecond_double;
double         rtemsTicksPerTwoSeconds_double;

static rtems_interval ini_ticks()
{
rtems_interval rval;
   rtems_clock_get (RTEMS_CLOCK_GET_TICKS_PER_SECOND, &rval);
   rtemsTicksPerSecond_double = (double)rval;
   rtemsTicksPerTwoSeconds_double = (double)rval * 2.0;
   return rval;
}
