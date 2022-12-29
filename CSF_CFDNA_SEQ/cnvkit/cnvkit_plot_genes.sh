#!/bin/bash

#Plot CNV alterations seperately for each chromosome with gene name annotation

#Input arguments
ID_T=$1
OUTPUT=$2
prefix=$3
chr=$4
genes=$5
home_dir=$6

#Directories
work_dir=$home_dir/data/results/${ID_T}
OUT_DIR=$OUTPUT/genes
mkdir -p $OUT_DIR

#Files
BAM_T=$work_dir/bam/${ID_T}.aligned.sort.bam

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
cnvkit=$home_dir/reference/cnvkit

##Script##
##Run cnvkit batch pipeline for aligned bam and matching normal
docker run --rm -v ${home_dir}:${home_dir} -v ${OUTPUT}:$OUTPUT -u $UID --memory 60G etal/cnvkit \
cnvkit.py scatter $OUTPUT/${prefix}.cnr \
--y-max 4 \
--y-min -4 \
-c $chr \
-g $genes \
-s $OUTPUT/${prefix}.cns \
--segment-color red \
-o $OUT_DIR/${ID_T}_${chr}_amplification.pdf 