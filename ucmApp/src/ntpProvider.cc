#include <epicsTime.h>
#include <sys/timex.h>
#include <rtems.h>

/*
* RTEMS time begins January 1, 1988 (local time).
* EPICS time begins January 1, 1990 (GMT).
*
* FIXME: How to handle daylight-savings time?
*/
#define EPICS_EPOCH_SEC_PAST_RTEMS_EPOCH ((366+365)*86400)
#define POSIX_TIME_SECONDS_1970_THROUGH_1988 \
 (((1987 - 1970 + 1)  * TOD_SECONDS_PER_NON_LEAP_YEAR) + \
      (4 * TOD_SECONDS_PER_DAY))

static unsigned long timeoffset = EPICS_EPOCH_SEC_PAST_RTEMS_EPOCH +
                                 POSIX_TIME_SECONDS_1970_THROUGH_1988;

extern "C"
{
int epics_ntp_gettime (epicsTimeStamp *pDest)
{
struct ntptimeval ntv;
   if ( ntp_gettime( &ntv ) )
       return epicsTimeERROR;
   pDest->nsec         = ntv.time.tv_nsec;
   pDest->secPastEpoch = ntv.time.tv_sec - timeoffset;
   return epicsTimeOK;
} 
}

