#!/bin/bash
training=$1

home_dir=/home/iser/cfDNA_docker
seeds=(42 117 67403 83926 4910296)
IDs=(274040 274042 274044 274046 279690)

for j in "${IDs[@]}"
do
    for i in "${seeds[@]}"
    do
        docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
        "python train_test_split.py \
        /home/iser/cfDNA_docker/reference/somaticseq_training/${training}/${j}/tsv/Ensemble.sSNV.tsv \
        /home/iser/cfDNA_docker/reference/somaticseq_training/${training}/${j}/tsv/Ensemble.sSNV.${i}.train.tsv \
        /home/iser/cfDNA_docker/reference/somaticseq_training/${training}/${j}/tsv/Ensemble.sSNV.${i}.test.tsv \
        $i"
    done
done

for j in "${IDs[@]}"
do
    for i in "${seeds[@]}"
    do
        docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
        "python train_test_split.py \
        /home/iser/cfDNA_docker/reference/somaticseq_training/${training}/${j}/tsv/Ensemble.sINDEL.tsv \
        /home/iser/cfDNA_docker/reference/somaticseq_training/${training}/${j}/tsv/Ensemble.sINDEL.${i}.train.tsv \
        /home/iser/cfDNA_docker/reference/somaticseq_training/${training}/${j}/tsv/Ensemble.sINDEL.${i}.test.tsv \
        $i"
    done
done
