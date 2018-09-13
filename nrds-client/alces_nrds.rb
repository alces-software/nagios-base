#!/bin/usr/ruby

nrds_config="/usr/local/nagios-base/nrds-client/nrds.cfg.dev"

puts nrds_config

if (File.file?(nrds_config))
    puts "Success! #{nrds_config} found."
else
    puts "Error! #{nrds_config} not found."
end

#
# Read the config file
#
file = File.open(nrds_config, "r")
data = file.read
file.close

puts data
