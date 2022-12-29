FROM broadinstitute/gatk
LABEL maintainer="f.iser@dkfz-heidelberg.de"

WORKDIR /mydata

RUN conda install -c bioconda tabix
RUN conda install -c bioconda bcftools
RUN conda install -c bioconda samtools
RUN conda install -c bioconda vt -y
RUN conda install -c bioconda bamtools
RUN pip install openpyxl
RUN pip install seaborn

COPY Plot_MYD88_L265P_locus.py .

#docker build -t 31071993/myd88_l265p .
