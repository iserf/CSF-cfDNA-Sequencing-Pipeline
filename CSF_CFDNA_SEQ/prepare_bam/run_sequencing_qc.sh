#!/bin/bash

#Calculate sequencing stats and create fastqc (multiqc) reports

#arguments
ID=$1
BED=$2
home_dir=$3

#Directories and log files
work_dir=$home_dir/CSF_CFDNA_SEQ/prepare_bam
LOG_DIR=$home_dir/data/results/${ID}/preprocess_bam_log
mkdir -p $LOG_DIR
LOG_FILE=$LOG_DIR/${ID}.qc.stdout.log
ERROR_FILE=$LOG_DIR/${ID}.qc.error.log

#Pipeline#
echo "Calculate sequencing stats and create fastqc (multiqc) reports" | tee $LOG_FILE
echo "Sample-ID: $ID" | tee -a $LOG_FILE
echo "Processing date:" | tee -a $LOG_FILE
date | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "Catch some basic QC stats: Flagstats and Picard CollectHsMetrics (gatk)" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$work_dir/stats.sh $ID $BED $home_dir 2>>$ERROR_FILE 1>>$LOG_FILE
wait

echo "" | tee -a $LOG_FILE
echo "Create FASTQC reports for trimmed fastqc files as well as raw and deduplicated bam files (fastqc, multiQC)" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$work_dir/fastqc.sh $ID $home_dir 2>>$ERROR_FILE 1>>$LOG_FILE
wait

#Pipeline done
echo "Sample ${ID}: QC done." | tee -a $LOG_FILE