#!/bin/bash

#
# This check will evolve to be more abstract.
# that is, instead of checking specifically for inlet temperature (and as such requred modification between HP and Dell machines,
# it should probably check for a string passed as an argument in one of the output files written to by the ipmitool.
#

# 
# f(machine name, warning_threshold, critical_threshold) = <OK|WARNING|CRITICAL>
#

if [[ -z "$1" ]] || [[ -z $2 ]] || [[ -z $3 ]] || [[  -z "$4" ]]; then
    echo "Error! Usage: $0 <machine name> <warning threshold> <critical threshold> <ipmi attribute>"
    exit 3
fi

machine_name="$1"
warning_threshold=$2
critical_threshold=$3
ipmi_attribute_check="$4"

file="$machine_name.ipmi.out"

ipmi_check_dir="/var/spool/nagios/ipmi-check"

#
# sanity check for inlettemp - there should be 1 and only 1 apperance of "inlet" in this file, if there is not, exit
#
# return 3 for unknown
#
count=$(grep -ci "${ipmi_attribute_check}" $ipmi_check_dir/$file)

if [ "$count" -ne "1" ]; then
    exit 3
fi

decval=`cat $ipmi_check_dir/$file 2> /dev/null | grep -i "${ipmi_attribute_check}" | head -1 | awk '{print $8}' | cut -d. -f1`

if [ $decval -ge $critical_threshold ]; then
    # output to stdout not interpreted here.
    exit 2
elif [ $decval -ge $warning_threshold ]; then
    exit 1
elif [ $decval -ge 0 ]; then
    exit 0
fi

exit 0
