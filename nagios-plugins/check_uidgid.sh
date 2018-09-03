#!/bin/bash
#
# On each machine:
#     Ensure Nagios user and group is present with the correct UID and GID respectively.
# 
# This script is rsynced accross, then is run each time an rsync occurs

expected_nagios_user="nagios"
expected_nagios_group=${expected_nagios_user}
expected_nagios_uid="$1"
expected_nagios_gid="$2"
destination_plugins_dir="$3"
destination_configs_dir="$4"

if [ -z ${expected_nagios_uid} ] || [ -z ${expected_nagios_gid} ]; then
    echo "Must supply both a UID for the Nagios User and a GID for the Nagios Group"
    exit 1
fi

if [ -z ${destination_plugins_dir} ] || [ -z ${destination_configs_dir} ]; then
    echo "Must supply the directory locations of the plugins and configs directory."
    exit 2 
fi

#
# check nagios user exists
# - it is not the job of this script to ensure the nagios user exists, but that the nagios user that does
# exist has the correct UID and GID
#

this_nagios_user=`id -u ${expected_nagios_user}`
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error! Expected user: ${expected_nagios_user} does not exist!"
    exit ${rc}
fi

#
# check nagios group exists
# - it is not the purpose of this script to create the nagios group, but to ensure that the existing nagios group
# has the correct UID and GID.
#

this_nagios_group=`id -g ${expected_nagios_group}`
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error! Expected group: ${expected_nagios_group} does not exist!"
    exit ${rc}
fi

#
# If the UID or GID is incorrect, then remove the user
# and create it fresh, otherwise skip.
#

echo ""
echo "Checking user and group ID..."
echo ""

if [ "${this_nagios_user}" != "${expected_nagios_uid}" ] || [ "${this_nagios_group}" != "${expected_nagios_gid}" ]; then
    echo ""
    echo "Nagios UID and GID not suitable, remediating..."
    echo ""

    #
    # We do not want a nagios user /home directory on these systems.
    #

    if [ ${this_nagios_user} -ge 1000 ]; then
        echo "${expected_nagios_user} has a regular user account."
	echo "Removing /home/${expected_nagios_user}"
	rm -rf /home/${expected_nagios_user}
	rc=$?
	if [ ${rc} -ne 0 ]; then
	    echo "Unable to remove home directory: /home/${expected_nagios_user}"
	    echo "Maybe it didn't exist anyway?"
	fi
    fi

    #
    # Assign new UID to nagios user - this will be a system ID ( < 1000 ), 810 by default
    #
    usermod -u ${expected_nagios_uid} ${expected_nagios_user}
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error! Unable to reassign uid: ${expected_nagios_uid} to user: ${expected_nagios_user}."
	exit 1
    fi

    echo ""
    echo "${expected_nagios_user} has had its UID corrected."
    echo ""

    #
    # Assign new GID to nagios group
    #
    groupmod -g ${expected_nagios_gid} ${expected_nagios_group}
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error! Unable to reassign gid: ${expected_nagios_gid} to group ${expected_nagios_group}"
	exit 1
    fi

    echo ""
    echo "${expected_nagios_group} has had its GID corrected."
    echo ""

    #
    # Assign new GID and UID ownership to plugins directory.
    #
    chown -R ${expected_nagios_uid}:${expected_nagios_gid} ${destination_plugins_dir}
    rc=$?
    if [ ${rc} -ne 0 ]; then
        echo "Error! Unable to change ownership of directory: ${destination_plugins_dir} to user: ${expected_nagios_uid} and group: ${expected_nagios_gid}"
	exit ${rc}
    fi

    echo ""
    echo "Ownership of ${destination_plugins_dir} has been updated according to the corrected UID and GID."
    echo ""

    #
    # Assign new GID and UID ownership to configs directory.
    #
    chown -R ${expected_nagios_uid}:${expected_nagios_gid} ${destination_configs_dir}
    if [ ${rc} -ne 0 ]; then
        echo "Error! Unable to change ownership of directory: ${destination_configs_dir} to user: ${expected_nagios_uid} and group: ${expected_nagios_gid}"
	exit ${rc}
    fi

    echo ""
    echo "Ownership of ${destination_plugins_dir} has been updated according to the corrected UID and GID."
    echo ""

    echo ""
    echo "Nagios UID and GID remediation complete."
    echo ""

fi

echo ""
echo "User and group ID fine..."
echo ""

exit 0
