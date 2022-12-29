#!/bin/bash

###This Pipeline creates a somaticseq SNV and INDEL classifier from twist cfDNA reference standards

#arguments
training=$1
ID_T1=$2
ID_T2=$3
ID_T3=$4
ID_T4=$5
ID_T5=$6
classifier=$7

#Directories and log files
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/reference/somaticseq_training/$training
LOG_DIR=$work_dir/training_log
mkdir -p $LOG_DIR
LOG_FILE=$LOG_DIR/${training}.stdout.log
ERROR_FILE=$LOG_DIR/${training}.error.log

##Pipeline##
echo "Train SomatiSeq Classifier with samples ${ID_T1}, ${ID_T2}, ${ID_T3}, ${ID_T4}, ${ID_T5} in SINGLE mode" | tee $LOG_FILE
echo "Classifier is develped under Training-ID: ${training}" | tee $LOG_FILE
echo "Processing date:" | tee -a $LOG_FILE
date | tee -a $LOG_FILE

samples=(${ID_T2} ${ID_T4})
for i in "${samples[@]}"
do
    echo "" | tee -a $LOG_FILE
    echo "$i: run_pipeline_prepare_training_data.sh" | tee -a $LOG_FILE
    date | tee -a $LOG_FILE
    ./run_pipeline_prepare_training_data.sh $i $training 2>>$ERROR_FILE 1>>$LOG_FILE
done
wait

echo "" | tee -a $LOG_FILE
echo "Train classifier" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
./train_somaticseq.sh $training $ID_T1 $ID_T2 $ID_T3 $ID_T4 $ID_T5 $classifier 2>>$ERROR_FILE 1>>$LOG_FILE

##Classifier training finished##
date | tee -a $LOG_FILE
echo "Training completed. Classifier for samples ${ID_T1}, ${ID_T2}, ${ID_T3}, ${ID_T4}, ${ID_T5} in SINGLE mode developed under Training-ID: ${training}" | tee -a $LOG_FILE
