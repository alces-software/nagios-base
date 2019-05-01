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

chmod +x /opt/nagios/nagios-plugins/*
rc=$?
if [ ${rc} -ne 0 ]; then
    exit 1
fi

chown -R nagios:nagios /opt/nagios/nrds-client
if [ ${rc} -ne 0 ]; then
    exit 1
fi

chown -R nagios:nagios /opt/nagios/nagios-plugins
if [ ${rc} -ne 0 ]; then
    exit 1
fi

exit 0
