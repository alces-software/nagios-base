#!/bin/bash

#
# This script attempts to determine the manner in which RAID health
# should be checked, then calls the appropriate check.
#

hpssacli_present=0

if [ -f /usr/sbin/hpssacli ]; then
   # echo "hpssacli installed."
   hpssacli_present=1
else
   # echo "No hpssacli detected."
   hpssacli_present=0
fi

softwareraid=0

if [ $(grep -ci "md[[:digit:]]" /proc/mdstat) -ge 1 ]; then
   # echo "Software RAID configured."
   softwareraid=1
else
   # echo "No software RAID configured."
   softwareraid=0
fi

#
# Executes if HW RAID (using HPSSACLI) in use and SW RAID is NOT.
#
if [ ${hpssacli_present} -eq 1 ] && [ ${softwareraid} -eq 0 ]; then
   /opt/nagios/nagios-plugins/check_hpe_SA_RAID
   exit 0
fi

#
# Executes if HW RAID (using HPSSACLI) is not in use and SW RAID IS.
#
if [ ${hpssacli_present} -eq 0 ] && [ ${softwareraid} -eq 1 ]; then
   /opt/nagios/nagios-plugins/check_swraid1.sh
   exit 0
fi 

exit 3
