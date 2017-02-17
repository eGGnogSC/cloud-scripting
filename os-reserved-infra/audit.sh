#!/usr/bin/bash

# This script iterates over all projects within an OpenStack cloud,
# grabs their absolute limits, formats the output into a minified json file,
# and transfers the json file to a remote web server.

#Cloud Site. This var will be used as the parent for the json data and the filename
location='CloudSite'
#Remote server to send json file to
server='user@host:/path/to/web/folder/.'
# Source rc file with admin privileges
source /path/to/openstack/source/rc
# Create json file with parent object
echo "{\"$location\":[" > ${location}_TENANT_UTIL.json
# Iterate over project list, grabbing project name
for i in `openstack project list | awk '{print $4}'| tail -n +4`
do
# append project json object to file
echo "{\"$i\":" | tr -d '\n' >> ${location}_TENANT_UTIL.json
# append project limits to file
openstack limits show -f json --absolute --project $i | tr -d '\n' | tr -d ' ' >> ${location}_TENANT_UTIL.json
# Close project json object
echo '},' >> ${location}_TENANT_UTIL.json
done
# OpenStack limits show presents the assigned resources for each project,
# however assigned resources haven't necessarily been consumed.
# This optional final json object records hypervisor stats to show resources
# that have been consumed within the cloud infrastructure.
echo "{\"HYPERVISOR\":" | tr -d '\n' >> ${location}_TENANT_UTIL.json
openstack hypervisor stats show -f json | tr -d '\n' | tr -d ' ' >> ${location}_TENANT_UTIL.json
echo '}]}' >> ${location}_TENANT_UTIL.json
scp ${location}_TENANT_UTIL.json $server
