ARG BUILD_FROM
FROM $BUILD_FROM

WORKDIR /root
COPY xray.sh /root/xray.sh
COPY config.sh /root/config.sh
COPY run.sh /
RUN chmod a+x /root/config.sh
RUN chmod a+x /run.sh

RUN set -ex \
	&& apk add --no-cache tzdata ca-certificates \
	&& mkdir -p /var/log/xray /usr/share/xray \
	&& chmod +x /root/xray.sh \
	&& /root/xray.sh \
	&& rm -fv /root/xray.sh \
	&& wget -O /usr/share/xray/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat \
	&& wget -O /usr/share/xray/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat

VOLUME /etc/xray
ENV TZ=Asia/Shanghai

CMD [ "/run.sh" ]
