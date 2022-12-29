FROM broadinstitute/gatk
LABEL maintainer="f.iser@dkfz-heidelberg.de"

WORKDIR /mydata

RUN conda install -c bioconda tabix
RUN conda install -c bioconda bcftools
RUN conda install -c bioconda samtools
RUN pip install openpyxl

COPY create_report.py .
COPY preprocess_SSeq_vcf.py .

COPY create_report_single.py .
COPY preprocess_SSeq_vcf_single.py .

#docker build -t 31071993/csf_cfdna_seq:snv_indel_report .
