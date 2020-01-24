#!/bin/bash

# Plugin to check slurm status

if [ ! -x /usr/bin/sinfo ] ; then
   echo "No sinfo command found - is slurm installed?"
   exit 3
fi

outputfile=/tmp/slurmoutput.$$

# Don't hang-up the plugin if sinfo takes too long to return
sudo /usr/bin/sinfo -Nl > $outputfile 2>&1 &
sleep 2

# Init variables
unexpected=0
totalnodes=0

# Add checks here
unexpected=`grep -i unexpected $outputfile | awk '{print $1}' | sort | uniq | wc -l | awk '{print $1}'`
lines=`cat $outputfile | awk '{print $1}' | sort | uniq | wc -l | awk '{print $1}'`
totalnodes=`expr $lines - 2`
down=`grep -i down $outputfile | awk '{print $1}' | sort | uniq | wc -l | awk '{print $1}'`
drain=`grep -i "drain" $outputfile | grep -v Alces | awk '{print $1}' | sort | uniq | wc -l | awk '{print $1}'`
alcesdrain=`grep -i "drain" $outputfile | grep Alces | awk '{print $1}' | sort | uniq |  wc -l | awk '{print $1}'`
killfailed=`grep -i "kill task failed" $outputfile | awk '{print $1}' | sort | uniq | wc -l | awk '{print $1}'`

rm -f $outputfile > /dev/null 2>&1

if [ $unexpected -gt 0 ] ; then
   echo "$unexpected node(s) reporting unexpected reboot ($down node(s) down)"
   exit 1
fi

if [ $killfailed -gt 0 ] ; then
   echo "$killfailed node(s) reporting kill task failed"
   exit 1
fi

if [ $down -gt 0 ] ; then
   echo "$down node(s) reporting down"
   exit 1
fi

# Add more conditions here

if [ $drain -gt 0 ] ; then
   if [ $alcesdrain -eq $drain ] ; then
      echo "$alcesdrain node(s) drained for maintenance by Alces"
      exit 0
   else
      echo "$drain node(s) reporting drained"
      exit 1
   fi
fi

# Final condition
echo "Slurm okay - detected $totalnodes running node(s)"
exit 0
