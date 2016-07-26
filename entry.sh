#!/bin/sh

if [ ! -z ${RANCHER_DEBUG} ]; then
    set -x
fi

ENV_FILE=/opt/rancher/bin/calico.env


retry=150
while [ ${retry} -gt 0 ]; do
    echo "Trying to find calico environment file"
    if [ -f ${ENV_FILE} ]; then
        echo "Found the environment file, sourcing it and starting calico"
        cat ${ENV_FILE}
        source ${ENV_FILE}

        ping_retry=150
        etcd="false"
        while [ ${ping_retry} -gt 0 -a "${etcd}" == "false" ]; do
            ping -c1 etcd
            if [ $? -eq 0 ]; then
                etcd="true"
            fi
            sleep 1
            ping_retry=$((ping_retry-1))
        done

        if [ "${etcd}" == "true" ]; then
            # Now execute the entrypoint of calico
            /sbin/start_runit
            exit 0
        else
            echo "Unable to find etcd"
            exit 1
        fi
    else
        sleep 1
        retry=$((retry-1))
    fi
    echo "retries remaining: ${retry}"
done

echo "calico environment file: ${ENV_FILE} not found"
exit 1
