# Data container based on busybox, to searve the gerrit container in this ci project
FROM busybox:latest
MAINTAINER kfmaster <fuhaiou@hotmail.com>
RUN mkdir -p /data; chmod 755 /data
VOLUME ["/data"]
COPY ipa-server-install-options  /data/ipa-server-install-options
COPY ipa-user-data /data/ipa-user-data
