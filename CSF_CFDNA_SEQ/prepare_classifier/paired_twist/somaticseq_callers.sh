#!/bin/bash

#Input arguments
ID_T=$1
ID_N=$2
BAM_T=$3
dedup=$4

#Directories
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/data/results/${ID_T}/variants/$dedup/somaticseq
OUT_DIR=$work_dir/somaticseq_callers
mkdir -p $OUT_DIR

#Files
BAM_DIR=$home_dir/data/results/${ID_T}/bam_ready
BAM_N=$home_dir/data/results/${ID_N}/bam/274000_aligned.sort.bam

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
BED=$home_dir/reference/bed/NPHD2019A_Covered_hg38.bed
DATA_SOURCE=$home_dir/reference/funcotator_dat_source_in_use
dbSNP=$home_dir/reference/funcotator_dat_source_in_use/dbsnp/hg38/hg38_All_20180418.vcf.gz

##Script##
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
"makeSomaticScripts.py paired \
--genome-reference $REFERENCE \
--inclusion-region $BED \
--tumor-bam $BAM_DIR/$BAM_T \
--normal-bam $BAM_N \
--tumor-sample-name $ID_T \
--normal-sample-name $ID_N \
--output-directory $OUT_DIR \
--dbsnp-vcf $dbSNP \
--minimum-VAF 0.0025 \
--run-mutect2 --run-varscan2 --run-vardict --run-scalpel --run-strelka2 --exome-setting \
--run-somaticseq \
--run-workflow --by-caller"
wait

chmod +x $OUT_DIR/logs/*
wait

parallel -j0 ::: $OUT_DIR/logs/*.cmd