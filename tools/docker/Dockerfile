FROM ubuntu

COPY dart /usr/bin
COPY app.dart.snapshot /root/bin/
ENTRYPOINT ["dart", "/root/bin/app.dart.snapshot", "-c", "/run/secrets/echannel_config"]

EXPOSE 80