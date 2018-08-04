FROM ubuntu:16.04

COPY Anaconda.sh /opt/Anaconda.sh

COPY install.sh /usr/bin/install.sh

COPY runconnector.sh /usr/bin/runconnector.sh

ENV PATH=/opt/anaconda/bin:$PATH \
    LANGUAGE=en_US.UTF-8         \
    LANG=en_US.UTF-8             \
    LC_ALL=C.UTF-8

RUN chmod +x /usr/bin/install.sh && bash install.sh

