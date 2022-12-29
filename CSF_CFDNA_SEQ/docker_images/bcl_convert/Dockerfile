FROM centos:7
LABEL maintainer="f.iser@dkfz-heidelberg.de"

WORKDIR /bcl-convert

COPY bcl-convert-3.9.3-2.el7.x86_64.rpm .

RUN yum localinstall -y ./bcl-convert-3.9.3-2.el7.x86_64.rpm

CMD  ["/bin/bash"]

#docker build -t 31071993/csf_cfdna_seq:bcl_convert .