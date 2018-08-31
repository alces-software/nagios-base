#!/bin/bash
#
# To be run on controller.pri.CLUSTER
#
#1. Clone checks repoistory
#2. Clone branch


#
# Make sure I am running as root
#

if [ `id -u` -ne 0 ]; then
    echo "Error! ${0} must be run as root."
    exit 1
fi

this_host=`hostname -f | sed -e s/.alces.network$//g`

#
# Make sure I am being run on the controller node
#

echo "${this_host}" | grep -i "^controller\."
is_controller=$?

# dev
is_controller=0

if [ ${is_controller} -ne 0 ]; then
    echo "This must be run on the controller!"
    exit 1
fi

installer_config_file="nagios_install.cfg"

if [ ! -f ${installer_config_file} ]; then
    echo "Installation config file not found!"
    exit 1
fi

# Unlikely, but just in case.
if [ ! -d ${parent_source_dir} ]; then
    echo "Error! Parent directory: ${parent_source_dir} does not exist!"
    exit 1
fi

#
# Get Nagios Plugins Repo URL from config file
#

nagios_plugins_repo=`grep -i "nagios_plugins_repo" ${installer_config_file} | sed -e 's/nagios_plugins_repo=//' | tr -d \"`

#
# Clone Nagios Base Repo: Plugins, Sync Scripts 
#

#
# Get the local directory that the plugins repo will be stored.
#

source_plugins_dir=`grep -i "source_plugins_dir" ${installer_config_file} | sed -e 's/source_plugins_dir=//' | tr -d \"`

git clone ${nagios_plugins_repo} ${source_plugins_dir}
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error cloning repo!"
    exit ${rc}
fi


#
# Get repo Nagios config URL from config file.
#

nagios_config_repo=`grep -i "nagios_config_repo" ${installer_config_file} | sed -e 's/nagios_config_repo=//' | tr -d \"`
echo "Nagios Config Repository is: ${nagios_config_repo}"

#
# Get the local directory that the configs repo will be stored.
#

source_configs_dir=`grep -i "source_configs_dir" ${installer_config_file} | sed -e 's/source_configs_dir=//' | tr -d \"`

# 
# Determine the cluster this is. We will fetch our own configuration.
#

# dev
test_hostname="controller.pri.csf3.alces.network"

this_cluster=`echo ${test_hostname} | sed -e 's/controller.pri.\(.*\).alces.network/\1/'`
echo "Cluster is: ${this_cluster}"

branch=${this_cluster}

echo "Cloning repo: ${nagios_config_repo}, branch: ${branch}"


#
# Clone Nagios Repo: the Branch I need
#
git clone -b ${branch} ${nagios_config_repo} ${source_configs_dir}
rc=$?
if [ ${rc} -ne 0 ]; then
    echo "Error cloning repo: ${nagios_config_branch}"
    exit ${rc}
fi

# Create the Nagios parent directory

#
# OK, launch sync script.
# 

#
# sync script gets launched 
# 

exit 0
