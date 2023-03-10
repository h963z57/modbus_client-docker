FROM debian

COPY ./source/files /source/files

RUN apt-get update \
    && apt-get install -y \
        /source/files/modbus-utils* \
        socat \
        openssh-server \
        cron \
        gettext-base \
        mailutils \
        sudo \
        python3-apt

RUN mkdir /run/modbus \
    && mkdir /var/log/modbus \
    && touch /var/log/modbus/selfhealling.log \
    && touch /var/log/modbus/socat.log \
    && touch /var/log/modbus/modbus_client.log

RUN sed -i '/session    required     pam_loginuid.so/c\#session    required   pam_loginuid.so' /etc/pam.d/cron \
    && chmod +x /source/files/selfhealling.sh \
    && echo "*/1   *   *   *   *   sh /source/files/selfhealling.sh >> /var/log/modbus/selfhealling.log" >> /var/spool/cron/crontabs/root

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]

EXPOSE 22