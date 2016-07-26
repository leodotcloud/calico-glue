#!/bin/sh

if [ ! -z ${RANCHER_DEBUG} ]; then
    set -x
fi

RANCHER_METADATA=rancher-metadata.rancher.internal
RANCHER_ETCD=etcd.kubernetes.rancher.internal

# These commands will break if the calico upstream
# changes their base image from alpine to something else
apk update && apk add wget curl

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

# Environment variables needed by Calico
export HOSTNAME=${hostname}
export IP=${ip}
export IP6=""
export CALICO_NETWORKING=true
export ETCD_AUTHORITY=${RANCHER_ETCD}:2379


ping_etc_retries=150
ping_etcd="false"
while [ ${ping_etc_retries} -gt 0 -a "${ping_etcd}" == "false" ]; do
    ping -c1 ${RANCHER_ETCD}
    if [ $? -eq 0 ]; then
        ping_etcd="true"
    fi
    sleep 1
    ping_etc_retries=$((ping_etc_retries-1))
done

if [ "${ping_etcd}" == "true" ]; then
    # Now execute the entrypoint of calico
    /sbin/start_runit
    exit 0
else
    echo "Unable to find etcd"
    exit 1
fi
