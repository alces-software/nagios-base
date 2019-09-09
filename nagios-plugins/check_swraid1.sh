#!/bin/bash

# Plugin to check status of software RAID1 disk

good=0
bad=0

if [ `grep -c U /proc/mdstat` -lt 1 ] ; then
   echo "No SW RAID1 configured"
   exit 0
elif [ `grep -c UU /proc/mdstat` -ge 1 ] ; then
   echo "Detected healthy RAID1 pair"
   exit 0
else
   echo "Detected faulty RAID1 set"
   exit 1
fi
