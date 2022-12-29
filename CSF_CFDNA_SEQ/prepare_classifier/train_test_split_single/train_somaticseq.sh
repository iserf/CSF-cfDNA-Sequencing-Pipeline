#!/bin/bash

#Input arguments
training=$1
seed=$2
ID_T1=274040
ID_T2=274042
ID_T3=274044
ID_T4=274046
ID_T5=279690

#Directories
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/reference/somaticseq_training/$training
OUT_DIR=$work_dir/classifiers/$seed
mkdir -p $OUT_DIR

#Resources
snv_tsv_T1=$work_dir/$ID_T1/tsv/Ensemble.sSNV.${seed}.train.tsv
snv_tsv_T2=$work_dir/$ID_T2/tsv/Ensemble.sSNV.${seed}.train.tsv
snv_tsv_T3=$work_dir/$ID_T3/tsv/Ensemble.sSNV.${seed}.train.tsv
snv_tsv_T4=$work_dir/$ID_T4/tsv/Ensemble.sSNV.${seed}.train.tsv
snv_tsv_T5=$work_dir/$ID_T5/tsv/Ensemble.sSNV.${seed}.train.tsv
indel_tsv_T1=$work_dir/$ID_T1/tsv/Ensemble.sINDEL.${seed}.train.tsv
indel_tsv_T2=$work_dir/$ID_T2/tsv/Ensemble.sINDEL.${seed}.train.tsv
indel_tsv_T3=$work_dir/$ID_T3/tsv/Ensemble.sINDEL.${seed}.train.tsv
indel_tsv_T4=$work_dir/$ID_T4/tsv/Ensemble.sINDEL.${seed}.train.tsv
indel_tsv_T5=$work_dir/$ID_T5/tsv/Ensemble.sINDEL.${seed}.train.tsv

##Script##
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
"somatic_xgboost.py train \
-tsvs $snv_tsv_T1 $snv_tsv_T2 $snv_tsv_T3 $snv_tsv_T4 $snv_tsv_T5 \
-out $OUT_DIR/${training}.${seed}.SNV.classifier \
-threads 8 -depth 12 -seed 42 -method hist -iter 250 \
--extra-params grow_policy:lossguide max_leaves:24"
wait

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
"somatic_xgboost.py train \
-tsvs $indel_tsv_T1 $indel_tsv_T2 $indel_tsv_T3 $indel_tsv_T4 $indel_tsv_T5 \
-out $OUT_DIR/${training}.${seed}.INDEL.classifier \
-threads 8 -depth 12 -seed 42 -method hist -iter 250 \
--extra-params grow_policy:lossguide max_leaves:24"