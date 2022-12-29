#!/bin/bash

###Call variants and prepare .tsv files for creation of a somaticseq SNV and INDEL classifier from twist cfDNA reference standards

#arguments
ID_T=$1
ID_N=$2
training=$3
SNV_truth=$4
Indel_truth=$5
BED=$6

#Directories and log files
script_dir=/home/iser/cfDNA_docker/pipeline_v2/prepare_classifier/train_classifiers_twist_paired
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/reference/somaticseq_training/$training/$ID_T
LOG_DIR=$work_dir/prepare_tsv_log
mkdir -p $LOG_DIR
LOG_FILE=$LOG_DIR/${ID_T}.stdout.log
ERROR_FILE=$LOG_DIR/${ID_T}.error.log

##Pipeline##
echo "Call variants and prepare .tsv files for creation of a somaticseq SNV and INDEL classifier from twist cfDNA reference standards" | tee $LOG_FILE
echo "ID-Tumor: $ID_T" | tee -a $LOG_FILE
echo "ID-Normal: $ID_N" | tee -a $LOG_FILE
echo "Classifier is develped under Training-ID: $training" | tee $LOG_FILE
echo "Processing date:" | tee -a $LOG_FILE
date | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "Run dockerized callers from lethalfang/somaticseq:latest: Mutect2, MuSE, Lofreq, VarScan2, Strelka2, Scalpel and VarDict" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$script_dir/somaticseq_callers.sh $ID_T $ID_N ${ID_T}.aligned.deduped.bam $training $BED 2>>$ERROR_FILE 1>>$LOG_FILE
wait

echo "" | tee -a $LOG_FILE
echo "Run octopus in --fast mode from dancooke/octopus and split output ${ID_T}_octopus_calls.vcf into ${ID_T}_octopus_calls.snv.vcf and ${ID_T}_octopus_calls.indel.vcf" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$script_dir/octopus.sh $ID_T $ID_N ${ID_T}.aligned.deduped.bam $training $BED 2>>$ERROR_FILE 1>>$LOG_FILE
wait

echo "" | tee -a $LOG_FILE
echo "Run SomaticSeq in training mode to prepare .tsv file. tsv-files of several samples are merged later and this merge is used to train the final classifier" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$script_dir/prepare_tsv.sh $ID_T $ID_N ${ID_T}.aligned.deduped.bam $training $SNV_truth $Indel_truth $BED 2>>$ERROR_FILE 1>>$LOG_FILE
wait

##Var calling finished##
date | tee -a $LOG_FILE
echo "Samples ${ID_T} and ${ID_N}: .tsv for classifier training are created under $work_dir/tsv" | tee -a $LOG_FILE
