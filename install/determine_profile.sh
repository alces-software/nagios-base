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

#
# Not a very "efficient" way of doing this:- is this a problem? It is done this way for it's simplicity.
#

while read cluster_machine; do

    echo ""
    echo "Locating Nagios Monitoring Profile for: ${cluster_machine}"
    echo ""

    machine_type=`echo "${cluster_machine}" | grep -o "^[[:alpha:]]*"`
    echo "machine_type is: ${machine_type}"

    #
    # Iterate through the file and see if there are any matches.
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

exit 0
