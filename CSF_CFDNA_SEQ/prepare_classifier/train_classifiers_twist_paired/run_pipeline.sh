#!/bin/bash

###This Pipeline creates a somaticseq SNV and INDEL classifier from twist cfDNA reference standards

#arguments
training=$1
ID_T1=$2
ID_T2=$3
ID_T3=$4
ID_T4=$5
ID_T5=$6
ID_N=$7
classifier=$8

#Directories and log files
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/reference/somaticseq_training/$training
LOG_DIR=$work_dir/training_log
mkdir -p $LOG_DIR
LOG_FILE=$LOG_DIR/${ID_T}.stdout.log
ERROR_FILE=$LOG_DIR/${ID_T}.error.log
script_dir=$home_dir/pipeline_v2/prepare_classifier/train_classifiers_twist_paired/

##Pipeline##
echo "Train SomatiSeq Classifier with samples ${ID_T1}, ${ID_T2}, ${ID_T3}, ${ID_T4}, ${ID_T5} and matching normal ${ID_N}" | tee $LOG_FILE
echo "Classifier is develped under Training-ID: ${training}" | tee $LOG_FILE
echo "Processing date:" | tee -a $LOG_FILE
date | tee -a $LOG_FILE

# samples=(${ID_T1} ${ID_T3} ${ID_T5})
# SNV_truth=$home_dir/reference/bed/sides_twist/SNV_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
# Indel_truth=$home_dir/reference/bed/sides_twist/All_Indel_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
# for i in "${samples[@]}"
# do
#     echo "" | tee -a $LOG_FILE
#     echo "$i: run_pipeline_prepare_training_data.sh" | tee -a $LOG_FILE
#     date | tee -a $LOG_FILE
#     $script_dir/run_pipeline_prepare_training_data.sh $i $ID_N $training $SNV_truth $Indel_truth 2>>$ERROR_FILE 1>>$LOG_FILE
# done
# wait

# samples=(${ID_T2} ${ID_T4})
# for i in "${samples[@]}"
# do
#     SNV_truth==$home_dir/data/results/$i/truth_set/SNV_merge2.vcf.gz
#     Indel_truth=$home_dir/data/results/$i/truth_set/Indel_merge2.vcf.gz
#     echo "" | tee -a $LOG_FILE
#     echo "$i: run_pipeline_prepare_training_data.sh" | tee -a $LOG_FILE
#     date | tee -a $LOG_FILE
#     ./run_pipeline_prepare_training_data.sh $i $ID_N $training $SNV_truth $Indel_truth 2>>$ERROR_FILE 1>>$LOG_FILE
# done
# wait

echo "" | tee -a $LOG_FILE
echo "Train classifier" | tee -a $LOG_FILE
date | tee -a $LOG_FILE
./train_somaticseq.sh $training $ID_T1 $ID_T2 $ID_T3 $ID_T4 $ID_T5 $classifier 2>>$ERROR_FILE 1>>$LOG_FILE

##Classifier training finished##
date | tee -a $LOG_FILE
echo "Training completed. Classifier for samples ${ID_T1}, ${ID_T2}, ${ID_T3}, ${ID_T4}, ${ID_T5} and matching normal ${ID_N} developed under Training-ID: ${training}" | tee -a $LOG_FILE
