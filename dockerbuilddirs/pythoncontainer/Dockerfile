FROM ubuntu:16.04

COPY Anaconda.sh /opt/tmp/Anaconda.sh

COPY runasroot.sh /usr/bin/runasroot.sh

COPY runasnonroot.sh /usr/bin/runasnonroot.sh

RUN chmod +x /usr/bin/runas*.sh && bash runasroot.sh

USER developer

WORKDIR /home/developer

ENV PATH=/opt/anaconda/bin:$PATH \
    LANG=en_US.UTF-8

RUN bash runasnonroot.sh

