#!/usr/bin/bash

# This script iterates over all projects within an OpenStack cloud,
# grabs their absolute limits, formats the output into a minified json file,
# and transfers the json file to a remote web server.
location='Cloud Site'
server='user@host:/path/to/web/folder/.'
source /home/stack/overcloudrc
echo "{\"$location\":[" > ${location}_TENANT_UTIL.json
for i in `openstack project list | awk '{print $4}'| tail -n +4`
do
echo "{\"$i\":" | tr -d '\n' >> ${location}_TENANT_UTIL.json
openstack limits show -f json --absolute --project $i | tr -d '\n' | tr -d ' ' >> ${location}_TENANT_UTIL.json
echo '},' >> ${location}_TENANT_UTIL.json
done
echo "{\"HYPERVISOR\":" | tr -d '\n' >> ${location}_TENANT_UTIL.json
openstack hypervisor stats show -f json | tr -d '\n' | tr -d ' ' >> ${location}_TENANT_UTIL.json
echo '}]}' >> ${location}_TENANT_UTIL.json
scp ${location}_TENANT_UTIL.json $server
