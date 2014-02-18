FROM sgrid-base

RUN yum -y -q install firefox xorg-x11-server-Xvfb

ADD start.sh /opt/start.sh
CMD ["/bin/bash", "/opt/start.sh"]
