#!/bin/bash

#
# Name of the file that roughly states the monitoring profile a node is a member of
#
approx_host_to_profile="host-to-profile-approx.cfg"

#
# Name of the file that will be used to store the machines we have on *this* cluster.
#
cluster_machines="cluster-nodes.cfg"

if [ ! -f ${approx_host_to_profile} ]; then
    echo "Error! ${approx_host_to_profile} file not found."
    exit 1
fi

#
# get all hosts
#

if [ -f ${cluster_machines} ]; then
    echo "Warning! ${cluster_machines} file already exists!!"
fi


#nodeattr -n all > ${cluster_machines}
#rc=$?
#if [ ${rc} -ne 0 ]; then
#    echo "Error, unable to get the output of nodeattr -n all"
#    exit 1
#fi

# for each entry in the cluster_machines

while read machine; do
    echo "Locating profile for: ${machine}"
    echo ""
    while read profile; do
       
       # get the line.

       echo ${read} | grep -o "${machine}"
       rc=$?
       if [ ${rc} ]; then
       fi
       
    done < ${approx_host_to_profile}

done < ${cluster_machines}

exit 0
