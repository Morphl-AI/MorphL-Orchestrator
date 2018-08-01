FROM ubuntu:16.04

COPY Anaconda.sh /opt/Anaconda.sh

COPY install.sh /usr/bin/install.sh

COPY runconnector.sh /usr/bin/runconnector.sh

ENV PATH=/opt/anaconda/bin:$PATH \
    LANG=en_US.UTF-8

RUN chmod +x /usr/bin/install.sh && bash install.sh

