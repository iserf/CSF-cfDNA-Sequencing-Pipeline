#!/bin/bash

#Input arguments
ID_T=$1
BAM_T=$2
home_dir=$3
BED=$4

#Directories
work_dir=$home_dir/data/results/${ID_T}/variants/somaticseq_single
OUT_DIR=$work_dir/somaticseq_callers
mkdir -p $OUT_DIR

#Files
BAM_DIR=$home_dir/data/results/${ID_T}/bam_ready

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
dbSNP=$home_dir/reference/funcotator_dat_source_in_use/dbsnp/hg38/hg38_All_20180418.vcf.gz

##Script##
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
"makeSomaticScripts.py single \
--genome-reference $REFERENCE \
--inclusion-region $BED \
--bam $BAM_DIR/$BAM_T \
--sample-name $ID_T \
--output-directory $OUT_DIR \
--dbsnp-vcf $dbSNP \
--minimum-VAF 0.0025 \
--run-mutect2 --run-varscan2 --run-lofreq --run-vardict --run-scalpel --run-strelka2 --exome-setting \
--run-somaticseq \
--run-workflow --by-caller"
wait

chmod +x $OUT_DIR/logs/*
wait

parallel -j0 ::: $OUT_DIR/logs/*.cmd