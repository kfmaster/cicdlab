# Clone from the Fedora 21 image
FROM fedora:21

MAINTAINER Jan Pazdziora

# Install FreeIPA client
RUN yum install -y deltarpm; yum install -y --skip-broken postfix dovecot freeipa-client hostname perl 'perl(Data::Dumper)' \
&& yum clean all

ADD dbus.service /etc/systemd/system/dbus.service
RUN ln -sf dbus.service /etc/systemd/system/messagebus.service

ADD systemctl /usr/bin/systemctl
ADD ipa-client-configure-first /usr/sbin/ipa-client-configure-first

RUN chmod -v +x /usr/bin/systemctl /usr/sbin/ipa-client-configure-first

COPY postfix-main.cf.template /root/postfix-main.cf.template

ENTRYPOINT /usr/sbin/ipa-client-configure-first
