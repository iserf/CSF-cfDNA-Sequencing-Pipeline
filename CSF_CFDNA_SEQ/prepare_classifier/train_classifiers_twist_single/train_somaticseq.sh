#!/bin/bash

#Input arguments
training=$1
ID_T1=$2
ID_T2=$3
ID_T3=$4
ID_T4=$5
ID_T5=$6
classifier=$7

#Directories
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/reference/somaticseq_training/$training
OUT_DIR=$home_dir/reference/somaticseq_training/classifiers_in_use/$classifier
mkdir -p $OUT_DIR

#Resources
snv_tsv_T1=$work_dir/$ID_T1/tsv/Ensemble.sSNV.tsv
snv_tsv_T2=$work_dir/$ID_T2/tsv/Ensemble.sSNV.tsv
snv_tsv_T3=$work_dir/$ID_T3/tsv/Ensemble.sSNV.tsv
snv_tsv_T4=$work_dir/$ID_T4/tsv/Ensemble.sSNV.tsv
snv_tsv_T5=$work_dir/$ID_T5/tsv/Ensemble.sSNV.tsv
indel_tsv_T1=$work_dir/$ID_T1/tsv/Ensemble.sINDEL.tsv
indel_tsv_T2=$work_dir/$ID_T2/tsv/Ensemble.sINDEL.tsv
indel_tsv_T3=$work_dir/$ID_T3/tsv/Ensemble.sINDEL.tsv
indel_tsv_T4=$work_dir/$ID_T4/tsv/Ensemble.sINDEL.tsv
indel_tsv_T5=$work_dir/$ID_T5/tsv/Ensemble.sINDEL.tsv

##Script##
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
"somatic_xgboost.py train \
-tsvs $snv_tsv_T1 $snv_tsv_T2 $snv_tsv_T3 $snv_tsv_T4 $snv_tsv_T5 \
-out $OUT_DIR/${training}.SNV.classifier \
-threads 8 -depth 12 -seed 42 -method hist -iter 250 \
--extra-params grow_policy:lossguide max_leaves:24"
wait

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
"somatic_xgboost.py train \
-tsvs $indel_tsv_T1 $indel_tsv_T2 $indel_tsv_T3 $indel_tsv_T4 $indel_tsv_T5 \
-out $OUT_DIR/${training}.INDEL.classifier \
-threads 8 -depth 12 -seed 42 -method hist -iter 250 \
--extra-params grow_policy:lossguide max_leaves:24"