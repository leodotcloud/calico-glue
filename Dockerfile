FROM alpine:3.4
MAINTAINER leodotcloud@gmail.com

RUN apk update && \
	apk add wget curl

RUN mkdir -p /opt/rancher/bin /opt/cni/bin /etc/cni/net.d && \
    wget https://github.com/projectcalico/calico-cni/releases/download/v1.3.1/calico \
         https://github.com/projectcalico/calico-cni/releases/download/v1.3.1/calico-ipam \
        -P /opt/cni/bin && \
	chmod +x /opt/cni/bin/calico /opt/cni/bin/calico-ipam

ADD new_entry.sh /opt/rancher/bin
ADD 10-calico.conf /etc/cni/net.d

VOLUME /opt/rancher/bin
VOLUME /opt/cni/bin
VOLUME /etc/cni/net.d

CMD	["sh"]
