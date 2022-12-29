FROM ubuntu:latest
LABEL maintainer="f.iser@dkfz-heidelberg.de"

RUN apt-get -y upgrade
RUN apt-get -y update
RUN apt install default-jre -y
RUN apt install wget -y

RUN apt-get install -y samtools

RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -b
ENV PATH=/root/miniconda3/bin:${PATH}

RUN conda update -y conda
RUN conda install -c bioconda bwa-mem2 -y

RUN rm Miniconda3-latest-Linux-x86_64.sh

#docker build -t 31071993/csf_cfdna_seq:bwa_mem2 .
