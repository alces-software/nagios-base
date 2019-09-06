#!/bin/bash                                                                                                                                                            
################################################################################
# (c) Copyright 2018 Stephen F Norledge & Alces Software Ltd.                  #
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

valid_ip="(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"

show_route=$(sudo /usr/sbin/lnetctl route show -v | grep -i "gateway\|state")
formatted_route=$(echo ${show_route} | sed 's|up\ |up\n|g')

gw_down="down"
gw_up="up"

nr_down=0
nr_up=0 
nr_other=0
nr_seen=0

while read -r line
do
    gateway=$(echo ${line} | grep -E -o "${valid_ip}")
    if [ $? -ne 0 ]; then
        echo "Error: Gateway not seen."
        exit 2
    fi
    gw_state=$(echo ${line} | grep -io "state.*" | cut -d":" -f 2 | tr -d ' ')
    if [ $? -ne 0 ]; then
        echo "Error: Gateway state not seen "
        exit 2
    fi

    ((nr_seen++))

    if [ "${gw_state}" == "${gw_up}" ]; then
        ((nr_up++))
    elif [ "${gw_state}" == "${gw_down}" ]; then
        ((nr_down++))
    else
        ((nr_other++))
    fi
    echo -n "Gateway: ${gateway} is ${gw_state}. "
done <<< "${formatted_route}"

#echo "nr_up:" ${nr_up}
#echo "nr_down:" ${nr_down}
#echo "nr_others:" ${nr_others}
#echo "nr_seen:" ${nr_seen}

if [ "${nr_seen}" == "${nr_up}" ]; then
    echo "OK - All detected gateways have state: up."
    exit 0
elif [ "${nr_down}" -gt 0 ] && [ "${nr_other}" -eq 0 ]; then
    echo "WARNING - ${nr_down} Gateway(s) have been lost!"
    exit 1
elif [ "${nr_seen}" == "${nr_down}" ] && [ "${nr_other}" -eq 0 ]; then
    echo "CRITICAL - All detected gateways have state: down!"
    exit 2
elif [ ${nr_other} -gt 0 ]; then
    echo "UNKNOWN - ${nr_others} gatewats in unknown state"
    exit 3
fi
