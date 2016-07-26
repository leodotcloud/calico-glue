#!/bin/sh

if [ ! -z ${RANCHER_DEBUG} ]; then
    set -x
fi

RANCHER_METADATA=rancher-metadata.rancher.internal

# Find hostname
hostname=`curl -s -f http://${RANCHER_METADATA}/2015-12-19/self/host/name`
retry=120
while [ "${hostname}" == "" -a ${retry} -gt 0 ]; do
    sleep 1
    echo "Trying to find hostname from metadata"
    hostname=`curl -s -f http://${RANCHER_METADATA}/2015-12-19/self/host/name`
    retry=$((retry-1))
done

if [ "${hostname}" == "" ]; then
    echo "Error: couldn't find the hostname from metadata"
    exit 1
else
    echo "Found hostname: ${hostname}"
fi

# Find ip
ip=`curl -s -f http://${RANCHER_METADATA}/2015-12-19/self/host/agent_ip`
retry=30
while [ "${ip}" == "" -a ${retry} -gt 0 ]; do
    sleep 1
    echo "Trying to find ip from metadata"
    ip=`curl -s -f http://${RANCHER_METADATA}/2015-12-19/self/host/agent_ip`
    retry=$((retry-1))
done

if [ "${ip}" == "" ]; then
    echo "Error: couldn't find the ip from metadata"
    exit 1
else
    echo "Found ip: ${ip}"
fi

cat > /opt/rancher/bin/calico.env << EOF
# Environment variables needed by Calico
export HOSTNAME=${hostname}
export IP=${ip}
export IP6=""
export CALICO_NETWORKING=true
export ETCD_AUTHORITY=etcd:2379
EOF

exit 0
