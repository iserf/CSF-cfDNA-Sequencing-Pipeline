FROM broadinstitute/gatk
LABEL maintainer="f.iser@dkfz-heidelberg.de"

RUN conda install -c bioconda tabix
RUN conda install -c bioconda bcftools
RUN conda install -c bioconda samtools
RUN conda install -c bioconda vt -y
RUN conda install -c bioconda bamtools

#docker build -t 31071993/csf_cfdna_seq:special_positions .


