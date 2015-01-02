FROM ubuntu:14.04
MAINTAINER chungsub.kim@purpleworks.co.kr

# update ubuntu latest
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get -qq update && \
  DEBIAN_FRONTEND=noninteractive apt-get -qq -y dist-upgrade #2014.08.24

# install essential packages
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get -qq -y install build-essential software-properties-common python-software-properties git wget

# install confd
RUN \
  mkdir -p /app && \
  wget -q -O /app/confd https://github.com/kelseyhightower/confd/releases/download/v0.7.1/confd-0.7.1-linux-amd64 

RUN   chmod +x /app/confd && \
  mkdir -p /etc/confd/conf.d && \
  mkdir -p /etc/confd/templates

# install haproxy
RUN \
  add-apt-repository ppa:vbernat/haproxy-1.5 
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get -qq update 
RUN \
  DEBIAN_FRONTEND=noninteractive apt-get -qq -y --force-yes install haproxy

# syslog configuration
RUN \
  echo "$ModLoad imudp" >> /etc/rsyslog.conf && \
  echo "$UDPServerAddress 127.0.0.1" >> /etc/rsyslog.conf && \
  echo "$UDPServerRun 514" >> /etc/rsyslog.conf

# add confd config
ADD haproxy.cfg.tmpl /etc/confd/templates/haproxy.cfg.tmpl
ADD haproxy.toml /etc/confd/conf.d/haproxy.toml

# add run
ADD run.sh /app/run.sh
RUN chmod +x /app/run.sh

# expose
EXPOSE 80

# run
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
CMD /app/run.sh
