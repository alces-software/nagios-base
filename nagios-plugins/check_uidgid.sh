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
# This script will delegate user creation of nagios to another script and runs if at least any one of the conditions are true:
# there is no nagios user installed
# this nagios user's UID is not as should be expected
# the nagios user's GID is not as should be expected
#
this_nagios_user=`id -u ${expected_nagios_user}`
rc=$?
if [ ${rc} -ne 0 ] || [ "${this_nagios_user}" != "${expected_nagios_uid}" ] || [ "${this_nagios_group}" != "${expected_nagios_gid}" ]; then
    echo "Error! Expected user: ${expected_nagios_user} does not exist!"
    echo "Calling create_usergroup.sh, I'm out of here..."
    source /usr/local/nagios-base/manual-checks/create_usergroup.sh ${expected_nagios_uid} ${expected_nagios_gid}
    rc=$?
    if [ ${rc} -ne 0 ]; then
        exit ${rc}
    else
        exit 0
    fi
fi

this_nagios_group=`id -g ${expected_nagios_group}`
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error! Expected group: ${expected_nagios_group} does not exist!"
    exit ${rc}
    source /usr/local/nagios-base/manual-checks/create_usergroup.sh ${expected_nagios_uid} ${expected_nagios_gid}
    rc=$?
    if [ ${rc} -ne 0 ]; then
        exit ${rc}
    else
        exit 0
    fi
fi
I

# 
# If the UID/GID was incorrect,
# Correct file ownership.
#

if [ "${this_nagios_user}" != "${expected_nagios_uid}" ] || [ "${this_nagios_group}" != "${expected_nagios_gid}" ]; then
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
