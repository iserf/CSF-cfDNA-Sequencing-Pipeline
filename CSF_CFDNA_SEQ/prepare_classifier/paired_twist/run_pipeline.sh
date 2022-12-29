#!/bin/bash

###This Pipeline finds somatic variants from a matched tumor-normal sample set, germline variants are not recognized.

#arguments
ID_T=$1
ID_N=$2
dedup=$3

BAM_T=${ID_T}.${dedup}.bqsr.bam


#Directories and log files
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/data/results/${ID_T}/variants/$dedup/somaticseq
LOG_DIR=$work_dir/pipeline_log
mkdir -p $LOG_DIR
LOG_FILE=$LOG_DIR/${ID_T}.stdout.log
ERROR_FILE=$LOG_DIR/${ID_T}.error.log

##Pipeline##
echo "RUN Pipeline v2 in PAIRED mode for a tumor bam file deduplicated with Picard MarkDuplicates" | tee $LOG_FILE
echo "ID-Tumor: $ID_T" | tee -a $LOG_FILE
echo "ID-Normal: $ID_N" | tee -a $LOG_FILE
echo "Processing date:" | tee -a $LOG_FILE
date | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "Run dockerized callers from lethalfang/somaticseq:latest: Mutect2, VarScan2, Strelka2, Scalpel and VarDict" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
./somaticseq_callers.sh $ID_T $ID_N $BAM_T $dedup 2>>$ERROR_FILE 1>>$LOG_FILE
wait

echo "" | tee -a $LOG_FILE
echo "Run octopus in --fast mode from dancooke/octopus and split output ${ID_T}_octopus_calls.vcf into ${ID_T}_octopus_calls.snv.vcf and ${ID_T}_octopus_calls.indel.vcf" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
./octopus.sh $ID_T $ID_N $BAM_T $dedup 2>>$ERROR_FILE 1>>$LOG_FILE
wait

echo "" | tee -a $LOG_FILE
echo "Generate Consensus SSeq.Classified.sSNV.vcf and SSeq.Classified.sINDEL.vcf using a SomaticSeq classifier trained on Twist cfDNA reference standards" | tee -a $LOG_FILE
echo "Output final variants to SSeq.Classified.sSNV.pass.vcf and SSeq.Classified.sINDEL.pass.vcf" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
./classify_variants.sh $ID_T $ID_N $BAM_T $dedup 2>>$ERROR_FILE 1>>$LOG_FILE
wait

##Var calling finished##
date | tee -a $LOG_FILE
echo "Samples ${ID_T} and ${ID_N}: Pipeline v2 in PAIRED mode completed" | tee -a $LOG_FILE
