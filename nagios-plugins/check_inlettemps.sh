#!/bin/bash

#
# Organise files to check
#
# $0 <config file>
#

config_file="/opt/nagios/nrds-client/controller.ipmi-temperatures.cfg"

source $config_file

ipmi_file_dir="/var/spool/nagios/ipmi-check"

#
# Parse log file and generate a list of ma
#
critical=0
high=0
good=0
unknown=0

for type in "${ipmi_temperatures[@]}"; do

    machine_type=`echo $type | cut -d: -f 1`
    warning_threshold=`echo $type | cut -d: -f 2`
    critical_threshold=`echo $type | cut -d: -f 3`
   
    files_to_check=`ls ${ipmi_file_dir}/${machine_type}*`

    for file in `echo $files_to_check`; do
        machine=`basename $file ".ipmi.out"`
        bash check_inlettemp.sh $machine $warning_threshold $critical_threshold
        rc=$?
        
        if [ $rc -eq 2 ] ; then
            critical=`expr $critical + 1`
        elif [ $rc -eq 1 ] ; then
            high=`expr $high + 1`
        elif [ $rc -eq 0 ] ; then
            good=`expr $good + 1`
        else
            unknown=`expr $unknown + 1`
	fi
    done
done


if [ $critical -gt 0 ] || [ $high -gt 0 ] ; then
   echo "Temperature alert - $critical > ${highalert}C, $high > ${lowalert}C, $good OK"
   exit 1
elif [ $unknown -gt 0 ] ; then
   echo "Temperature OK ($good OK, $unknown did not report)"
   exit 0
else
   echo "Temperature OK on $good servers"
fi
