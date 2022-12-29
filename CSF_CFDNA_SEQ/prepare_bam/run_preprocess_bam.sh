#!/bin/bash

#Pipeline to create aligned (hg38), deduplicated (AGeNT CReaK DUPLEX) and bsqr (gatk) aligned bam files from raw fastq files. 
#Input recquires R1 & R2 fastq files in directory: /home_dir/data/results/{ID}/fastq

#arguments
ID=$1
BED=$2
DEDUP=$3
home_dir=$4

#Directories and log files
work_dir=$home_dir/CSF_CFDNA_SEQ/prepare_bam
LOG_DIR=$home_dir/data/results/${ID}/preprocess_bam_log
mkdir -p $LOG_DIR
LOG_FILE=$LOG_DIR/${ID}.preprocess_bam.stdout.log
ERROR_FILE=$LOG_DIR/${ID}.preprocess_bam.error.log

#Pipeline#
echo "Raw fastq data preprocessing pipeline for a library prepared with the SureSelect XT HS2 DNA Reagent Kit and sequenced as recommended in the manufacturers protocol" | tee $LOG_FILE
echo "Sample-ID: $ID" | tee -a $LOG_FILE
echo "Processing date:" | tee -a $LOG_FILE
date | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "Trim reads: Tool: AGeNT Trimmer" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$work_dir/trimmer.sh $ID $BED $home_dir 2>>$ERROR_FILE 1>>$LOG_FILE
wait

echo "" | tee -a $LOG_FILE
echo "Align to hg38 reference genome: Tool: bwa-mem2" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$work_dir/bwa_mem2.sh $ID $home_dir 2>>$ERROR_FILE 1>>$LOG_FILE
wait

echo "" | tee -a $LOG_FILE
echo "Deduplication: Tool: AGeNT CReaK in Duplex mode" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$work_dir/CReaK.sh $ID $BED $DEDUP $home_dir 2>>$ERROR_FILE 1>>$LOG_FILE
wait

#Pipeline done
echo "Sample ${ID} preprocessing done: Ready for variant calling" | tee -a $LOG_FILE