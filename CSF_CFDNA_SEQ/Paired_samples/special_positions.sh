#!/bin/bash

#Input arguments
ID_T=$1
BAM_T=$2
home_dir=$3

#Directories
work_dir=$home_dir/data/results/${ID_T}/variants/somaticseq
OUT_DIR=$work_dir/special_positions
mkdir -p $OUT_DIR

#Files
BAM_raw=$home_dir/data/results/${ID_T}/bam/${ID_T}.aligned.sort.bam
BAM_dedup=$home_dir/data/results/${ID_T}/bam_ready/$BAM_T

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
DATA_SOURCE=$home_dir/reference/funcotator_dat_source_in_use
special_positions=$home_dir/reference/bed/special_positions.tsv

##Script##

#RAW BAM#
#create mpileup
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 100G 31071993/cfdna_pipeline_v2:pipeline_v2_special /bin/bash -c \
"bcftools mpileup \
--regions-file $special_positions \
-d 100000 \
--fasta-ref $REFERENCE \
-o $OUT_DIR/${ID_T}_special_positions.raw_bam.vcf -O v \
--annotate FORMAT/AD,FORMAT/ADF,FORMAT/ADR,FORMAT/DP,FORMAT/SP,INFO/AD,INFO/ADF,INFO/ADR \
$BAM_raw"

docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 100G 31071993/cfdna_pipeline_v2:pipeline_v2_special /bin/bash -c \
"vt decompose -s $OUT_DIR/${ID_T}_special_positions.raw_bam.vcf \
-o $OUT_DIR/${ID_T}_special_positions.raw_bam.decompose.vcf"

#Funcotation
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 100G 31071993/cfdna_pipeline_v2:pipeline_v2_special \
gatk Funcotator \
--data-sources-path $DATA_SOURCE \
--ref-version hg38 \
-R $REFERENCE \
-V $OUT_DIR/${ID_T}_special_positions.raw_bam.decompose.vcf \
-O $OUT_DIR/${ID_T}_special_positions.raw_bam.annotated.maf \
--output-file-format MAF

grep "^[^#;]" $OUT_DIR/${ID_T}_special_positions.raw_bam.annotated.maf | awk -F '\t' '{print $1, $5, $6, $7, $9, $10, $11, $13, $40, $42, $81, $82, $142}' \
>  $OUT_DIR/${ID_T}_special_positions.raw_bam.report.maf


#DEDUPED BAM#

#create mpileup
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 100G 31071993/cfdna_pipeline_v2:pipeline_v2_special /bin/bash -c \
"bcftools mpileup \
--regions-file $special_positions \
-d 100000 \
--fasta-ref $REFERENCE \
-o $OUT_DIR/${ID_T}_special_positions.DUPLEX_bam.vcf -O v \
--annotate FORMAT/AD,FORMAT/ADF,FORMAT/ADR,FORMAT/DP,FORMAT/SP,INFO/AD,INFO/ADF,INFO/ADR \
$BAM_dedup"

docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 100G 31071993/cfdna_pipeline_v2:pipeline_v2_special /bin/bash -c \
"vt decompose -s $OUT_DIR/${ID_T}_special_positions.DUPLEX_bam.vcf \
-o $OUT_DIR/${ID_T}_special_positions.DUPLEX_bam.decompose.vcf"

#Funcotation
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 100G 31071993/cfdna_pipeline_v2:pipeline_v2_special \
gatk Funcotator \
--data-sources-path $DATA_SOURCE \
--ref-version hg38 \
-R $REFERENCE \
-V $OUT_DIR/${ID_T}_special_positions.DUPLEX_bam.decompose.vcf \
-O $OUT_DIR/${ID_T}_special_positions.DUPLEX_bam.annotated.maf \
--output-file-format MAF

grep "^[^#;]" $OUT_DIR/${ID_T}_special_positions.DUPLEX_bam.annotated.maf | awk -F '\t' '{print $1, $5, $6, $7, $9, $10, $11, $13, $40, $42, $81, $82, $142}' \
>  $OUT_DIR/${ID_T}_special_positions.DUPLEX_bam.report.maf