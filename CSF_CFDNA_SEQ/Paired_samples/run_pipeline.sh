#!/bin/bash

#This Pipeline finds somatic variants (SNVs/ INDELs) from a matched tumor-normal sample set
#germline variants are not reported

#arguments
ID_T=$1
ID_N=$2
classifier=$3
BED=$4
home_dir=$5

BAM_T=${ID_T}.aligned.deduped.bam


#Directories and log files
work_dir=$home_dir/data/results/${ID_T}/variants/somaticseq
mkdir -p $work_dir
pipeline_DIR=$home_dir/CSF_CFDNA_SEQ/Paired_samples
LOG_DIR=$work_dir/pipeline_log
mkdir -p $LOG_DIR
LOG_FILE=$LOG_DIR/${ID_T}.stdout.log
ERROR_FILE=$LOG_DIR/${ID_T}.error.log


##Pipeline##
echo "Run CSF_CFDNA_SEQ Variant Calling Pipeline in PAIRED mode" | tee $LOG_FILE
echo "ID-Tumor: $ID_T" | tee -a $LOG_FILE
echo "ID-Normal: $ID_N" | tee -a $LOG_FILE
echo "Processing date:" | tee -a $LOG_FILE
date | tee -a $LOG_FILE

echo "" | tee -a $LOG_FILE
echo "Perform Fingerprint to check same origin of ${ID_T} and ${ID_N}" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$pipeline_DIR/fingerprint.sh $ID_T $ID_N $BAM_T $home_dir 2>>$ERROR_FILE 1>>$LOG_FILE
wait

echo "" | tee -a $LOG_FILE
echo "Run dockerized callers from lethalfang/somaticseq:latest: Mutect2, VarScan2, Strelka2, Scalpel, VarDict, LoFreq and MuSE" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$pipeline_DIR/somaticseq_callers.sh $ID_T $ID_N $BAM_T $home_dir $BED 2>>$ERROR_FILE 1>>$LOG_FILE
wait

echo "" | tee -a $LOG_FILE
echo "Run octopus variant caller from dancooke/octopus and split output ${ID_T}_octopus_calls.vcf into ${ID_T}_octopus_calls.snv.vcf and ${ID_T}_octopus_calls.indel.vcf" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$pipeline_DIR/octopus.sh $ID_T $ID_N $BAM_T $home_dir $BED 2>>$ERROR_FILE 1>>$LOG_FILE
wait

echo "" | tee -a $LOG_FILE
echo "Classify ensemble SNV and INDEL calls: Somaticseq" | tee -a $LOG_FILE
echo "Classifier output files: SSeq.Classified.sSNV.vcf and SSeq.Classified.sINDEL.vcf" | tee -a $LOG_FILE
echo "Classifier used: ${classifier} " | tee -a $LOG_FILE
echo "Output final variants to SSeq.Classified.sSNV.pass.vcf and SSeq.Classified.sINDEL.pass.vcf" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$pipeline_DIR/classify_variants_2.sh $ID_T $ID_N $BAM_T $home_dir $classifier $BED 2>>$ERROR_FILE 1>>$LOG_FILE
wait

echo "" | tee -a $LOG_FILE
echo "gatk Funcotator: SSeq.Classified.sSNV.pass.vcf and SSeq.Classified.sINDEL.pass.vcf" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$pipeline_DIR/funcotation_2.sh $ID_T $home_dir $BED 2>>$ERROR_FILE 1>>$LOG_FILE
wait

echo "" | tee -a $LOG_FILE
echo "Create Special positions file for locations specified in: ${home_dir}/reference/bed/special_positions.tsv" | tee -a $LOG_FILE
echo "This file contains coverage at the given locations in the raw bam file as well as the deduplicated bam" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$pipeline_DIR/special_positions.sh $ID_T $BAM_T $home_dir 2>>$ERROR_FILE 1>>$LOG_FILE
wait

echo "" | tee -a $LOG_FILE
echo "Write classified and annotated variants, hard-filtered variants and special positions to a excel report at: ${work_dir}/report/${ID_T}.pipeline_v2.report.xlsx" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$pipeline_DIR/report_2.sh $ID_T $home_dir 2>>$ERROR_FILE 1>>$LOG_FILE
wait

echo "" | tee -a $LOG_FILE
echo "Create oncoprint file" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
$pipeline_DIR/Create_oncoprint_file.sh $ID_T $home_dir 
wait

##Variant calling finished##
date | tee -a $LOG_FILE
echo "Samples ${ID_T} and ${ID_N}: CSF_CFDNA_SEQ in PAIRED mode completed" | tee -a $LOG_FILE
