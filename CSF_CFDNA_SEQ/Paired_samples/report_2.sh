#!/bin/bash

#Input arguments
ID_T=$1
home_dir=$2

#Directories
work_dir=$home_dir/data/results/${ID_T}/variants/somaticseq
OUT_DIR=$work_dir/report
mkdir -p $OUT_DIR

#Files
SNV_raw=$work_dir/classify_variants/SSeq.Classified.sSNV.vcf
INDEL_raw=$work_dir/classify_variants/SSeq.Classified.sINDEL.vcf
SNV=$work_dir/classify_variants/${ID_T}.SSeq.Classified.sSNV.annotated.maf
INDEL=$work_dir/classify_variants/${ID_T}.SSeq.Classified.sINDEL.annotated.maf
special_positions_raw=$work_dir/special_positions/${ID_T}_special_positions.raw_bam.annotated.maf
special_positions_deduped=$work_dir/special_positions/${ID_T}_special_positions.${dedup}_bam.annotated.maf
SNV_clinvar=$work_dir/classify_variants/${ID_T}.SSeq.sSNV.preprocessed.annotated.maf
Indel_clinvar=$work_dir/classify_variants/${ID_T}.SSeq.sINDEL.preprocessed.annotated.maf

#intersect sites
report=$OUT_DIR/${ID_T}.CSF_CFDNA_SEQ.report.xlsx

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
DATA_SOURCE=$home_dir/reference/funcotator_dat_source_in_use
dbSNP=$home_dir/reference/funcotator_dat_source_in_use/dbsnp/hg38/hg38_All_20180418.vcf.gz

##Scripts
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 100G 31071993/cfdna_pipeline_v2:pipeline_v2_report /bin/bash -c \
"python /mydata/preprocess_SSeq_vcf.py $SNV_raw ${SNV_raw}.preprocessed.vcf"

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 100G 31071993/cfdna_pipeline_v2:pipeline_v2_report /bin/bash -c \
"python /mydata/preprocess_SSeq_vcf.py $INDEL_raw ${INDEL_raw}.preprocessed.vcf"

#Funcotation SNV
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 100G broadinstitute/gatk \
gatk Funcotator \
--data-sources-path $DATA_SOURCE \
--ref-version hg38 \
-R $REFERENCE \
-V ${SNV_raw}.preprocessed.vcf \
-O $SNV_clinvar \
--output-file-format MAF \
--disable-sequence-dictionary-validation

#Funcotation INDEL
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 100G broadinstitute/gatk \
gatk Funcotator \
--data-sources-path $DATA_SOURCE \
--ref-version hg38 \
-R $REFERENCE \
-V ${INDEL_raw}.preprocessed.vcf \
-O $Indel_clinvar \
--output-file-format MAF \
--disable-sequence-dictionary-validation


#create excel report
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -v /mnt/h:/mnt/h -u $UID --memory 100G 31071993/cfdna_pipeline_v2:pipeline_v2_report /bin/bash -c \
"python /mydata/create_report_2.py $SNV $INDEL $SNV_clinvar $Indel_clinvar $special_positions_raw $special_positions_deduped $report"
