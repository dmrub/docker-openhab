# Openhab 1.8.3
# * configuration is injected
#
FROM openjdk:8-jre
MAINTAINER Tom Deckers <tom@ducbase.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y install unzip supervisor wget curl && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG OPENHAB_VERSION=1.8.3
ARG OPENHAB_ADDONS_URL=https://bintray.com/openhab/mvn/download_file?file_path=org%2Fopenhab%2Fdistro%2Fopenhab%2F1.9.0%2Fopenhab-1.9.0-addons.zip

ENV OPENHAB_OPENHAB_CFG=
ENV OPENHAB_ADDONS_CFG=

#
# Download openHAB based on Environment OPENHAB_VERSION
#
COPY files/scripts/download_openhab.sh /root/
RUN /root/download_openhab.sh && \
    rm /root/download_openhab.sh

COPY files/supervisord.conf /etc/supervisor/supervisord.conf
COPY files/openhab.conf /etc/supervisor/conf.d/openhab.conf
COPY files/openhab_debug.conf /etc/supervisor/conf.d/openhab_debug.conf
COPY files/boot.sh /usr/local/bin/boot.sh
COPY files/openhab.sh /usr/local/bin/openhab.sh
COPY files/openhab-restart /etc/network/if-up.d/openhab-restart

EXPOSE 8080 8443 5555 9001

CMD ["/usr/local/bin/boot.sh"]
