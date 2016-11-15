#!/bin/sh

if [ ! -z ${RANCHER_DEBUG} ]; then
    set -x
fi

SRC_DIR=/opt/rancher
CNI_CONFIG_FILE_NAME=10-calico.conf
CNI_PLUGIN_FILE_NAME=calico
IPAM_FILE_NAME=calico-ipam

CNI_CONFIG_DIRECTORY=/etc/net.d/cni
CNI_BIN_DIRECTORY=/opt/cni/bin

if [ ! -d "{CNI_CONFIG_DIRECTORY}" ]; then
    echo "Error: Couldn't find ${CNI_CONFIG_DIRECTORY}, this should have been available from 'volumes_from'"
    exit 1
fi

# Remove any existing config files
rm -f ${CNI_CONFIG_DIRECTORY}/*.conf

# Copy the CNI config file
cp ${SRC_DIR}/${CNI_CONFIG_FILE_NAME} ${CNI_CONFIG_DIRECTORY}/${CNI_CONFIG_FILE_NAME}
if [ $? -ne 0 ]; then
    echo "Error: Couldn't copy the config file to ${CNI_CONFIG_DIRECTORY}"
    exit 1
fi

# Remove any existing binaries
rm -f ${CNI_BIN_DIRECTORY}/*

# Copy the CNI plugin
cp ${SRC_DIR}/${CNI_PLUGIN_FILE_NAME} ${CNI_BIN_DIRECTORY}/${CNI_PLUGIN_FILE_NAME}
if [ $? -ne 0 ]; then
    echo "Error: Couldn't copy the config file to ${CNI_BIN_DIRECTORY}"
    exit 1
fi

# Copy the IPAM plugin
cp ${SRC_DIR}/${IPAM_FILE_NAME} ${CNI_BIN_DIRECTORY}/${IPAM_FILE_NAME}
if [ $? -ne 0 ]; then
    echo "Error: Couldn't copy the config file to ${CNI_BIN_DIRECTORY}"
    exit 1
fi

exit 0
