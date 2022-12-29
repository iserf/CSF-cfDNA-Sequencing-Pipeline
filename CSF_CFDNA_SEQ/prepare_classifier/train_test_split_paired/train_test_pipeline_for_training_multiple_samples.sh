#!/bin/bash

workdir=/home/iser/cfDNA_docker/pipeline_v2/train_test_split_paired

trainings = (22-03-25_paired_t_xthsv1_n_xthsv1 22-03-27_paired_t_markduplicates_n_xthsv2)

for j in "${trainings[@]}"
do
    $workdir/train_test_pipeline_for_training_set.sh $j
done