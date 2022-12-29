#!/bin/bash

workdir=/home/iser/cfDNA_docker/pipeline_v2/train_test_split

trainings=(22-03-25_single_t_xthsv1)

for j in "${trainings[@]}"
do
    $workdir/train_test_pipeline_for_training_set.sh $j
done