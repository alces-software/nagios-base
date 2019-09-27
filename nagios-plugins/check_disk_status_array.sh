#!/bin/bash
# script to retrieve disk array status
export PATH=/opt/metalware/opt/pdsh/bin:/opt/metalware/opt/genders/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin

[[ ! -d /var/spool/nagios/array-check ]] && mkdir -p /var/spool/nagios/array-check && chown -R nagios /var/spool/nagios/array-check

. /etc/profile

for array in hablkary1-1 hablkary1-2 hablkary1-3 hablkary1-4 hablkary2-1 hablkary2-2 hablkary2-3 hablkary2-4 hablkary3-1 hablkary3-2 hablkary3-3 hablkary3-4 masterary1 metaary1 metaary2
do
   touch /var/spool/nagios/array-check/$array.out
   /usr/lib64/nagios/plugins/alces/check_msa_hardware.pl ${array}c1 > /tmp/arraycheck.$$ 2>&1

   # Primary controller may have failed - try secondary controller
   if [ `grep -c UNKNOWN /tmp/arraycheck.$$ | awk '{print $1}'` -ge 1 ] ; then
      retry=1
      /usr/lib64/nagios/plugins/alces/check_msa_hardware.pl ${array}c2 > /tmp/arraycheck.$$ 2>&1
   fi

   # Occassionally, the array are too busy for SNMP to work - wait for a few seconds then retry first controller
   if [ `grep -c UNKNOWN /tmp/arraycheck.$$ | awk '{print $1}'` -ge 1 ] ; then
      retry=2
      sleep 30
      /usr/lib64/nagios/plugins/alces/check_msa_hardware.pl ${array}c1 > /tmp/arraycheck.$$ 2>&1
   fi

   # Try secondary controller after delay
   if [ `grep -c UNKNOWN /tmp/arraycheck.$$ | awk '{print $1}'` -ge 1 ] ; then
      retry=3
      sleep 30
      /usr/lib64/nagios/plugins/alces/check_msa_hardware.pl ${array}c2 > /tmp/arraycheck.$$ 2>&1
   fi

   # Lastly, copy to status file
   cat /tmp/arraycheck.$$ > /var/spool/nagios/array-check/$array.out
   rm -f /tmp/arraycheck.$$ > /dev/null 2>&1
done
