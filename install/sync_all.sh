#!/bin/bash

# 
# Now both repos are available on us (controller).
#

#
# sync the plugins to each target.
#

installer_config_file="nagios_install.cfg"

source_plugins_dir=`grep -i "source_plugins_dir" ${installer_config_file} | sed -e 's/source_plugins_dir=//' | tr -d \"`
echo ${source_plugins_dir}

if [ ! -d ${source_plugins_dir} ]; then
    echo "Error! Plugins repo does not exist!"
    exit 1
fi

source_configs_dir=`grep -i "source_configs_dir" ${installer_config_file} | sed -e 's/source_configs_dir=//' | tr -d \"`
echo ${source_configs_dir}

if [ ! -d ${source_configs_dir} ]; then
    echo "Error! Configs directory does not exist!"
    exit 1
fi

#
# Read the location of the source and destination filesystem locations for the plugins and the configs from the config file.
#

destination_plugins_dir=`grep -i "destination_plugins_dir" ${installer_config_file} | sed -e 's/destination_plugins_dir=//' | tr -d \"`
echo ${destination_plugins_dir}

destination_configs_dir=`grep -i "destination_configs_dir" ${installer_config_file} | sed -e 's/destination_configs_dir=//' | tr -d \"`
echo ${destination_configs_dir}

#
# rsync all files from the source to the destination machines
#

# how to get the value of the destination machine?
destination_machine="127.0.0.1"

echo ""
echo "Syncing plugins..."
echo ""


# -e flag with the ssh command and identify file not needed in production version!
sudo rsync -aCvz -e "ssh -i /root/.ssh/id_rsa" ${source_plugins_dir}/ ${destination_machine}:${destination_plugins_dir} --delete
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Errori syncing plugins! rsync error code is: ${rc}"
    exit 1
fi

echo ""
echo "Plugins now synced."
echo ""

echo ""
echo "Syncing configs..."
echo ""

sudo rsync -aCvz -e "ssh -i /root/.ssh/id_rsa" ${source_configs_dir}/ ${destination_machine}:${destination_configs_dir} --delete
if [ ${rc} -ne 0 ]; then
    echo "Error syncing configs! rsync error code is: ${rc}"
    exit 1
fi

echo ""
echo "Configs now synced."
echo ""

echo ""
echo "Checking user is correct."
echo ""

#
# Check the nagios user's UID and GID is set correctly.
#
nagios_user_uid=`grep -i "nagios_user_id" ${installer_config_file} | sed -e 's/nagios_user_id=//' | tr -d \"`
nagios_group_gid=`grep -i "nagios_group_id" ${installer_config_file} | sed -e 's/nagios_group_gid=//' | tr -d \"`

ssh ${destination_machine} ${destination_plugins_dir}/nagios-plugins/check_uidgid.sh ${nagios_user_uid} ${nagios_group_gid}
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error remotely executing: check_uidgid.sh"
    exit 1
fi

echo ""
echo "User correct."
echo ""

exit 0
