#!/bin/bash

ID_N=279692
#dedup = locatit_xthsv1, locatit_xthsv2
dedup=DUPLEX
training=22_08_10_${dedup}_single

#Directories
home_dir=/home/iser/cfDNA_docker
OUT_DIR=/home/iser/cfDNA_docker/data/results/make_classifier
work_dir=$home_dir/pipeline_v2
mkdir -p $OUT_DIR/run_scripts

BED=$home_dir/reference/bed/NPHD2019A_Covered_hg38.bed

samples1=(274040 274042 274044 274046 279690)
samples2=(274042 274046)
samples3=(274040 274044 279690)


##############
##Preprocess##
##############

# echo "good night"
# sleep 24h
# echo "good morning!"
# date

#Rename directories
results=/home/iser/cfDNA_docker/data/results
storage_drive1=/mnt/e/22-06-27_All_data_reference_sample_training/22.05-15_create_classifier_train_samples/22-06-30_DUPLEX
storage_drive2=/mnt/e/22-06-27_All_data_reference_sample_training

#mv $results/27* $storage_drive2/22-06-27_LOCATIT_XTHSV2_SINGLE
#wait

# for i in "${samples1[@]}"
# do
#     #cp -r $results/ID $results/$i
#     mv $storage_drive1/$i $results
# done
# wait

# #Rename directoriesa
# for i in "${samples1[@]}"
# do
#     mv $results/$i/bam_ready_${dedup} $results/$i/bam_ready
# done
# wait

# for i in "${samples2[@]}"
# do
#     mv $results/$i/trainingSet_${dedup} $results/$i/trainingSet
#     mv $results/$i/truth_set_${dedup} $results/$i/truth_set
# done
# wait

# #############
# #Train-Tests#
# #############

# #Call variants
# SNV_truth=$home_dir/reference/bed/sides_twist/SNV_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
# Indel_truth=$home_dir/reference/bed/sides_twist/All_Indel_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
# for i in "${samples3[@]}"
# do
#     echo $i
#     touch $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
#     echo '#!/bin/bash' > $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
#     echo $work_dir/prepare_classifier/train_classifiers_twist_single/run_pipeline_prepare_training_data.sh $i $training $SNV_truth $Indel_truth $BED >> $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh

#     chmod +x $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
#     $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
# done
# wait

for i in "${samples2[@]}"
do
    echo $i
    SNV_truth=$home_dir/data/results/$i/truth_set/SNV_merge2.vcf.gz
    Indel_truth=$home_dir/data/results/$i/truth_set/Indel_merge2.vcf.gz
    touch $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
    echo '#!/bin/bash' > $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
    echo $work_dir/prepare_classifier/train_classifiers_twist_single/run_pipeline_prepare_training_data.sh $i $training $SNV_truth $Indel_truth $BED >> $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh

    chmod +x $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
    $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
done
wait

#train_test_split_single
mkdir -p $home_dir/reference/somaticseq_training/$training/train_test_split_log
LOG_FILE=$home_dir/reference/somaticseq_training/$training/train_test_split_log/stdout.log
ERROR_FILE=$home_dir/reference/somaticseq_training/$training/train_test_split_log/error.log

touch $OUT_DIR/run_scripts/${i}.${dedup}.train_test_split.sh
echo '#!/bin/bash' > $OUT_DIR/run_scripts/${i}.${dedup}.train_test_split.sh
echo $work_dir/prepare_classifier/train_test_split_single/train_test_pipeline_for_training_set.sh $training >> $OUT_DIR/run_scripts/${i}.${dedup}.train_test_split.sh

chmod +x $OUT_DIR/run_scripts/${i}.${dedup}.train_test_split.sh
$OUT_DIR/run_scripts/${i}.${dedup}.train_test_split.sh 2>>$ERROR_FILE 1>>$LOG_FILE
wait

#Generate final classifier
mkdir -p $home_dir/reference/somaticseq_training/$training/final_classifier_log
LOG_FILE=$home_dir/reference/somaticseq_training/$training/final_classifier_log/stdout.log
ERROR_FILE=$home_dir/reference/somaticseq_training/$training/final_classifier_log/error.log

touch $OUT_DIR/run_scripts/single.${dedup}.final_classifier.sh
echo '#!/bin/bash' > $OUT_DIR/run_scripts/single.${dedup}.final_classifier.sh
echo $work_dir/prepare_classifier/train_classifiers_twist_single/train_somaticseq.sh $training 274040 274042 274044 274046 279690 classifier_${dedup} >> $OUT_DIR/run_scripts/single.${dedup}.final_classifier.sh

chmod +x $OUT_DIR/run_scripts/single.${dedup}.final_classifier.sh
$OUT_DIR/run_scripts/single.${dedup}.final_classifier.sh 2>>$ERROR_FILE 1>>$LOG_FILE

# #Rename directoriesa
# for i in "${samples1[@]}"
# do
#     mv $results/$i/bam_ready $results/$i/bam_ready_${dedup}
# done
# wait

# for i in "${samples2[@]}"
# do
#     mv $results/$i/trainingSet $results/$i/trainingSet_${dedup}
#     mv $results/$i/truth_set $results/$i/truth_set_${dedup}
# done
# wait