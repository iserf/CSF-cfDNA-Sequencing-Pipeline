#!/bin/bash
training=$1

workdir=/home/iser/cfDNA_docker/pipeline_v2/prepare_classifier/train_test_split_paired
seeds=(42 117 67403 83926 4910296)

for i in "${seeds[@]}"
do
    $workdir/train_somaticseq.sh $training $i
done
wait

for i in "${seeds[@]}"
do
    classifier_snv=/home/iser/cfDNA_docker/reference/somaticseq_training/$training/classifiers/${i}/${training}.${i}.SNV.classifier
    classifier_indel=/home/iser/cfDNA_docker/reference/somaticseq_training/$training/classifiers/${i}/${training}.${i}.INDEL.classifier
    
    $workdir/classify_test_split.sh $training $i $classifier_snv $classifier_indel
done