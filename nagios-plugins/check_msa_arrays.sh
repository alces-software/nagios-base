#!/bin/bash
################################################################################
# (c) Copyright 2007-2011 Alces Software Ltd                                   #
#                                                                              #
# HPC Cluster Toolkit                                                          #
#                                                                              #
# This file/package is part of the HPC Cluster Toolkit                         #
#                                                                              #
# This is free software: you can redistribute it and/or modify it under        #
# the terms of the GNU Affero General Public License as published by the Free  #
# Software Foundation, either version 3 of the License, or (at your option)    #
# any later version.                                                           #
#                                                                              #
# This file is distributed in the hope that it will be useful, but WITHOUT     #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License #
# for more details.                                                            #
#                                                                              #
# You should have received a copy of the GNU Affero General Public License     #
# along with this product.  If not, see <http://www.gnu.org/licenses/>.        #
#                                                                              #
# For more information on Alces Software, please visit:                        #
# http://www.alces-software.org/                                               #
#                                                                              #
################################################################################

# Script to check the status of a status file for a HP MSA disk array
# array name is passed as parameter 1

array=$1

if [ `echo $array | egrep -c "c1$" | awk '{print $1}'` -gt 0 ] ; then
   array=`echo $array | sed 's?c1$??g'`
fi

checkfile=/var/spool/nagios/array-check/$array.out

if [ ! -f $checkfile ] ; then
   echo "No status file found for $array"
   exit 3
fi

# The check file has one line and simply includes the words OK, WARNING, CRITICAL or UNKNOWN to show status
# Parse the file and exit with the right exit code
if [ `grep -c OK $checkfile | awk '{print $1}'` -ge 1 ] ; then
   echo -n "$array : "
   cat $checkfile
   exit 0
elif [ `grep -c WARNING $checkfile | awk '{print $1}'` -ge 1 ] ; then
   echo -n "$array : "
   cat $checkfile
   exit 1
elif [ `grep -c CRITICAL $checkfile | awk '{print $1}'` -ge 1 ] ; then
   echo -n "$array : "
   cat $checkfile
   exit 2
else
   echo -n "$array : "
   cat $checkfile
   exit 3
fi

# Should not reach here
exit 3
