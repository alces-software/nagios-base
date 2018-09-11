#!/bin/bash

#
# This script, will be run on the controller machine.
# It looks to see which machines are members of the cluster, then using the generic machine to Nagios Monitoring Profile mapping structure,
# creates a file containing a mapping of "short hostnames" to Nagios Monitoring Profiles.
#

#
# File that contains the mappings of machine "types" to profiles, e.g. nodeXY to node, backupXY to backup, ossXY to oss, etc.
#
approx_host_to_profile="host-to-profile-approx.cfg"

if [ ! -f ${approx_host_to_profile} ]; then
    echo "Error! ${approx_host_to_profile} file not found."
    exit 1
fi

#
# Name of the file that will contain (once this script is run), a list of the nodes that are members of the cluster this script is run on.
#
cluster_machines="cluster-nodes.cfg"

if [ -f ${cluster_machines} ]; then
    echo "Warning! ${cluster_machines} file already exists!! Backing it up and continuing..."
    cp -p ${cluster_machines} ${cluster_machines}.bak
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error making a backup of ${cluster_machines}, something is not right here, better take a look before you leap (to the next stage)."
	exit 1
    fi
fi

config_file="determine-profile.cfg"
if [ ! -f ${config_file} ]; then
    echo "Error! Config File: ${config_file} not found!"
    exit 1
fi

genders_group=`grep -i "^genders_group:" ${config_file} | cut -d: -f 2`
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error! Unable to find genders_group in config file: ${config_file}!"
    exit 1
fi

nodeattr -n ${genders_group} > ${cluster_machines}
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error, unable to get the output of nodeattr -n all"
    exit 1
fi

#
# Not a very "efficient" way of doing this:- is this a problem? It is done this way for it's simplicity.
# Iterate through each machine in the the cluster, as listed in the output from nodeattr
#     Look for a suitable Monitoring profile
#     Output "short hostname":monitoring profile, e.g. node01:nodes; vlogin01:login, backup01:backups
# 
# There will need to be some overrides here. Just like in metal configure!
# For instance:
#     In this script, infra02 will be given a 'basic' profile, because all other infra nodes have basic.
#

if [ ! -f ${cluster_machines} ]; then
    echo "Error! File: ${cluster_machines} not found!"
    exit 1
fi

while read cluster_machine; do

    echo ""
    echo "Locating Nagios Monitoring Profile for: ${cluster_machine}"
    echo ""

    #
    # Extract the first alphabetical set of characters from the host name, e.g. given node02, get node; given vlogin01, get vlogin
    #

    machine_type=`echo "${cluster_machine}" | grep -o "^[[:alpha:]]*"`
    echo "machine_type is: ${machine_type}"

    #
    # Find the correct monitoring profile for each machine "type" 
    #

    while read machine_type_profile; do

	if echo "${machine_type_profile}" | egrep -iq "^${machine_type}"; then
            profile=`echo ${machine_type_profile} | egrep -io "[A-Za-z0-9-]*$"`
	    echo "${profile}"
	    echo "${cluster_machine}:${profile}" >> cluster_monitoring_profile.cfg
	    break;
        fi

    done < ${approx_host_to_profile}

done < ${cluster_machines}

if [ ! -f cluster_monitoring_profile.cfg ]; then
    echo "Error! File cluster_monitoring_profile.cfg is missing"
    exit 1
else
    echo "File: cluster_monitoring_profile.cfg is now available."
fi

exit 0
