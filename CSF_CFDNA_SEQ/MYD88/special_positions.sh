#!/bin/bash

#Input arguments
ID_T=$1
home_dir=$2

#Directories
work_dir=$home_dir/data/results/${ID_T}
OUT_DIR=$work_dir/MYD88_L265P
mkdir -p $OUT_DIR

#Files
BAM_raw=$home_dir/data/results/${ID_T}/bam/${ID_T}.aligned.sort.bam
BAM_dedup=$home_dir/data/results/${ID_T}/bam_ready/${ID_T}.aligned.deduped.bam

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
DATA_SOURCE=$home_dir/reference/funcotator_dat_source_in_use
special_positions=$home_dir/CSF_CFDNA_SEQ/MYD88/ressources/special_positions.tsv
BED=$home_dir/CSF_CFDNA_SEQ/MYD88/ressources/MYD88_amplicon.bed


##Script##

#RAW BAM#

#create mpileup
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 200G 31071993/myd88_l265p /bin/bash -c \
"bcftools mpileup \
--regions-file $special_positions \
-d 10000 \
--fasta-ref $REFERENCE \
-o $OUT_DIR/${ID_T}_special_positions.raw_bam.vcf -O v \
--annotate FORMAT/AD,FORMAT/ADF,FORMAT/ADR,FORMAT/DP,FORMAT/SP,INFO/AD,INFO/ADF,INFO/ADR \
$BAM_raw"

docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 200G 31071993/myd88_l265p /bin/bash -c \
"vt decompose -s $OUT_DIR/${ID_T}_special_positions.raw_bam.vcf \
-o $OUT_DIR/${ID_T}_special_positions.raw_bam.decompose.vcf"

#Funcotation
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 200G 31071993/myd88_l265p \
gatk Funcotator \
--data-sources-path $DATA_SOURCE \
--ref-version hg38 \
-R $REFERENCE \
-V $OUT_DIR/${ID_T}_special_positions.raw_bam.decompose.vcf \
-O $OUT_DIR/${ID_T}_special_positions.raw_bam.annotated.maf \
--output-file-format MAF


#DEDUPED BAM#

#create mpileup
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 200G 31071993/myd88_l265p /bin/bash -c \
"bcftools mpileup \
--regions-file $special_positions \
-d 10000 \
--fasta-ref $REFERENCE \
-o $OUT_DIR/${ID_T}_special_positions.DUPLEX_bam.vcf -O v \
--annotate FORMAT/AD,FORMAT/ADF,FORMAT/ADR,FORMAT/DP,FORMAT/SP,INFO/AD,INFO/ADF,INFO/ADR \
$BAM_dedup"

docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 200G 31071993/myd88_l265p /bin/bash -c \
"vt decompose -s $OUT_DIR/${ID_T}_special_positions.DUPLEX_bam.vcf \
-o $OUT_DIR/${ID_T}_special_positions.DUPLEX_bam.decompose.vcf"

#Funcotation
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 200G 31071993/myd88_l265p \
gatk Funcotator \
--data-sources-path $DATA_SOURCE \
--ref-version hg38 \
-R $REFERENCE \
-V $OUT_DIR/${ID_T}_special_positions.DUPLEX_bam.decompose.vcf \
-O $OUT_DIR/${ID_T}_special_positions.DUPLEX_bam.annotated.maf \
--output-file-format MAF


#PLOT DATA#
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 100G 31071993/myd88_l265p /bin/bash -c \
"python /mydata/Plot_MYD88_L265P_locus.py $OUT_DIR/${ID_T}_special_positions.raw_bam.annotated.maf $OUT_DIR/${ID_T}_special_positions.raw_bam.annotated"

docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 100G 31071993/myd88_l265p /bin/bash -c \
"python /mydata/Plot_MYD88_L265P_locus.py $OUT_DIR/${ID_T}_special_positions.DUPLEX_bam.annotated.maf $OUT_DIR/${ID_T}_special_positions.DUPLEX_bam.annotated"