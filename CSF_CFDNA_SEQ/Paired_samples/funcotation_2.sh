#!/bin/bash

#Input arguments
ID_T=$1
home_dir=$2
BED=$3

#Directories
work_dir=$home_dir/data/results/${ID_T}/variants/somaticseq
OUT_DIR=$work_dir/classify_variants
mkdir -p $OUT_DIR

#Files
SNV=$OUT_DIR/SSeq.Classified.sSNV.pass.vcf
INDEL=$OUT_DIR/SSeq.Classified.sINDEL.pass.vcf

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
DATA_SOURCE=$home_dir/reference/funcotator_dat_source_in_use


##Scripts
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 100G 31071993/cfdna_pipeline_v2:pipeline_v2_report /bin/bash -c \
"python /mydata/preprocess_SSeq_vcf.py $SNV ${SNV}.preprocessed.vcf"

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 100G 31071993/cfdna_pipeline_v2:pipeline_v2_report /bin/bash -c \
"python /mydata/preprocess_SSeq_vcf.py $INDEL ${INDEL}.preprocessed.vcf"

#Funcotation SNV
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 100G broadinstitute/gatk \
gatk Funcotator \
--data-sources-path $DATA_SOURCE \
--ref-version hg38 \
-R $REFERENCE \
-V ${SNV}.preprocessed.vcf \
-O $OUT_DIR/${ID_T}.SSeq.Classified.sSNV.annotated.maf \
--output-file-format MAF \
--disable-sequence-dictionary-validation

#Funcotation INDEL
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 100G broadinstitute/gatk \
gatk Funcotator \
--data-sources-path $DATA_SOURCE \
--ref-version hg38 \
-R $REFERENCE \
-V ${INDEL}.preprocessed.vcf \
-O $OUT_DIR/${ID_T}.SSeq.Classified.sINDEL.annotated.maf \
--output-file-format MAF \
--disable-sequence-dictionary-validation