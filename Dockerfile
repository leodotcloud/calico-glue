FROM alpine:3.4
MAINTAINER leodotcloud@gmail.com

RUN apk update && \
	apk add wget curl

RUN mkdir -p /opt/rancher/bin && \
    wget https://github.com/projectcalico/calico-cni/releases/download/v1.3.1/calico \
         https://github.com/projectcalico/calico-cni/releases/download/v1.3.1/calico-ipam \
        -P /opt/rancher && \
	chmod +x /opt/rancher/calico /opt/rancher/calico-ipam

ADD new_entry.sh /opt/rancher/bin
ADD 10-calico.conf /opt/rancher/10-calico.conf

VOLUME /opt/rancher

ENTRYPOINT ["/usr/bin/entry.sh"]
