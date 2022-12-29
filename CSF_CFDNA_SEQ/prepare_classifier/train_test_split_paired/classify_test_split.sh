#!/bin/bash

#Input arguments
training=$1
seed=$2
classifier_snv=$3
classifier_indel=$4

#Directories
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/reference/somaticseq_training/$training
OUT_DIR=$work_dir/classifiers/$seed
mkdir -p $OUT_DIR

IDs=(274040 274042 274044 274046 279690)

for i in "${IDs[@]}"
do
    snv_tsv=$work_dir/$i/tsv/Ensemble.sSNV.${seed}.test.tsv
    indel_tsv=$work_dir/$i/tsv/Ensemble.sINDEL.${seed}.test.tsv
    mkdir -p $OUT_DIR/test/$i

    ##Script##
    docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
    "somatic_xgboost.py predict \
    -model $classifier_snv \
    -tsv $snv_tsv \
    -out $OUT_DIR/test/$i/Ensemble.sSNV.${seed}.test.predicted.tsv"
    wait

    docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
    "SSeq_tsv2vcf.py \
    -tsv $OUT_DIR/test/$i/Ensemble.sSNV.${seed}.test.predicted.tsv \
    -vcf $OUT_DIR/test/$i/Ensemble.sSNV.${seed}.test.predicted.vcf \
    -all \
    -tools MuTect2 VarScan2 VarDict MuSE LoFreq Strelka Caller_0"
    wait

    docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
    "somatic_xgboost.py predict \
    -model $classifier_indel \
    -tsv $indel_tsv \
    -out $OUT_DIR/test/$i/Ensemble.sINDEL.${seed}.test.predicted.tsv"
    wait

    docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
    "SSeq_tsv2vcf.py \
    -tsv $OUT_DIR/test/$i/Ensemble.sINDEL.${seed}.test.predicted.tsv \
    -vcf $OUT_DIR/test/$i/Ensemble.sINDEL.${seed}.test.predicted.vcf \
    -all \
    -tools MuTect2 VarScan2 VarDict LoFreq Strelka Scalpel Caller_0"

done