#!/bin/bash

host=$2
warning=$4
critical=$6
nr_packets=$8

output=$(/opt/nagios/nagios-plugins/check_ping -H $host -w $warning -c $critical -p $nr_packets)
rc=$?

echo $output

if [ "$rc" -eq "1" ]; then
    exit 2
elif [ "$rc" -eq "2" ]; then
    exit 1
fi
