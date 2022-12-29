FROM broadinstitute/gatk
LABEL maintainer="f.iser@dkfz-heidelberg.de"

ENV HTTP_PROXY="http://www-int2.dkfz-heidelberg.de:3128"
ENV HTTPS_PROXY="http://www-int2.dkfz-heidelberg.de:3128"

WORKDIR /mydata

RUN conda install -c bioconda tabix
RUN conda install -c bioconda bcftools
RUN conda install -c bioconda samtools
RUN pip install openpyxl

COPY train_test_split.py .

#docker build -t 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split .
