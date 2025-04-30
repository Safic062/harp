FROM ghcr.io/xtls/xray-core:25.3.6

WORKDIR /root

COPY config.sh /root/config.sh
COPY run.sh /

RUN apk add --update bash
ENTRYPOINT ["/bin/bash"]

RUN chmod a+x /root/config.sh
RUN chmod a+x /run.sh

VOLUME /etc/xray

CMD [ "/run.sh" ]
