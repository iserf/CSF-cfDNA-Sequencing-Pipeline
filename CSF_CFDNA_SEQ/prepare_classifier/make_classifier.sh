#!/bin/bash

ID_N=279692
bwa_mode=bwa_mem2_xthsv2
#dedup = locatit_xthsv1, locatit_xthsv2 or markduplicates
dedup=SINGLE
training=22_07_04_${dedup}

#Directories
home_dir=/home/iser/cfDNA_docker
OUT_DIR=/home/iser/cfDNA_docker/data/results/make_classifier
work_dir=$home_dir/pipeline_v2
mkdir -p $OUT_DIR/run_scripts

samples0=(279692 274040 274042 274044 274046 279690)
samples1=(274040 274042 274044 274046 279690)
samples2=(274042 274046)
samples3=(274040 274044 279690)

BED=$home_dir/reference/bed/NPHD2019A_Covered_hg38.bed

##############
##Preprocess##
##############


# #Copy trimmed fastq into WSL
# results=/home/iser/cfDNA_docker/data/results
# storage_drive=/mnt/e/22-06-27_All_data_reference_sample_training/22.05-15_create_classifier_train_samples

# #mv $results/27* $storage_drive/22-07-03_HYBRID

# for i in "${samples1[@]}"
# do
#     cp -r $results/ID $results/$i
#     mv $storage_drive/22-06-30_DUPLEX/$i/fastq/* $results/$i/fastq
# done
# wait


# #Rename directories
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

# for i in "${samples1[@]}"
# do
#     cp -r $results/ID $results/$i
#     mv $storage_drive/22-06-20_LOCATIT_XTHSV2_DUPLEX/$i/fastq/* $results/$i/fastq
# done
# wait

# #Log files
# for i in "${samples1[@]}"
# do
#     LOG_DIR=$home_dir/data/results/${i}/preprocess_bam_${dedup}
#     mkdir -p $LOG_DIR
#     LOG_FILE=$LOG_DIR/${i}.stdout.log
#     ERROR_FILE=$LOG_DIR/${i}.error.log
# done
# wait

# #bwa_mem2
# for i in "${samples0[@]}"
# do
#     echo $i
#     LOG_FILE=$home_dir/data/results/${i}/preprocess_bam_${dedup}/${i}.dedup.stdout.log
#     ERROR_FILE=$home_dir/data/results/${i}/preprocess_bam_${dedup}/${i}.dedup.error.log
#     mkdir -p $home_dir/data/results/${i}/preprocess_bam_${dedup}

#     touch $OUT_DIR/run_scripts/${i}.${dedup}.bwa_mem2.sh
#     echo '#!/bin/bash' > $OUT_DIR/run_scripts/${i}.${dedup}.bwa_mem2.sh
#     echo $work_dir/prepare_bam/${bwa_mode}.sh $i >> $OUT_DIR/run_scripts/${i}.${dedup}.bwa_mem2.sh

#     chmod +x $OUT_DIR/run_scripts/${i}.${dedup}.bwa_mem2.sh
#     $OUT_DIR/run_scripts/${i}.${dedup}.bwa_mem2.sh 2>>$ERROR_FILE 1>>$LOG_FILE
# done
# wait

# #Deduplication
# for i in "${samples0[@]}"
# do
#     echo $i
#     LOG_FILE=$home_dir/data/results/${i}/preprocess_bam_${dedup}/${i}.dedup.stdout.log
#     ERROR_FILE=$home_dir/data/results/${i}/preprocess_bam_${dedup}/${i}.dedup.error.log
#     mkdir -p $home_dir/data/results/${i}/preprocess_bam_${dedup}

#     touch $OUT_DIR/run_scripts/${i}.${dedup}.sh
#     echo '#!/bin/bash' > $OUT_DIR/run_scripts/${i}.${dedup}.sh
# #    echo $work_dir/prepare_bam/${dedup}.sh $i $i*MBC*.txt.gz >> $OUT_DIR/run_scripts/${i}.${dedup}.sh
#     echo $work_dir/prepare_bam/CReaK.sh $i $BED $dedup >> $OUT_DIR/run_scripts/${i}.${dedup}.sh

#     chmod +x $OUT_DIR/run_scripts/${i}.${dedup}.sh
#     $OUT_DIR/run_scripts/${i}.${dedup}.sh 2>>$ERROR_FILE 1>>$LOG_FILE
# done
# wait

# #Deduplication normal: CReaK HYBRID
# echo $ID_N
# LOG_FILE=$home_dir/data/results/${ID_N}/preprocess_bam_HYBRID/${ID_N}.dedup.stdout.log
# ERROR_FILE=$home_dir/data/results/${ID_N}/preprocess_bam_HYBRID/${ID_N}.dedup.stdout.log
# mkdir -p $home_dir/data/results/${ID_N}/preprocess_bam_HYBRID

# touch $OUT_DIR/run_scripts/${ID_N}.HYBRID.sh
# echo '#!/bin/bash' > $OUT_DIR/run_scripts/${ID_N}.HYBRID.sh
# echo $work_dir/prepare_bam/CReaK.sh $ID_N $BED HYBRID >> $OUT_DIR/run_scripts/${ID_N}.HYBRID.sh

# chmod +x $OUT_DIR/run_scripts/${ID_N}.HYBRID.sh
# $OUT_DIR/run_scripts/${ID_N}.HYBRID.sh 2>>$ERROR_FILE 1>>$LOG_FILE
# wait

# #bamsurgeon
# for i in "${samples2[@]}"
# do  
#     echo $i
#     touch $OUT_DIR/run_scripts/${i}.${dedup}.bam_surgeon.sh
#     echo '#!/bin/bash' > $OUT_DIR/run_scripts/${i}.${dedup}.bam_surgeon.sh
#     echo $work_dir/prepare_classifier/bam_surgeon/prepare_artificial_tumor_normal.sh $i $ID_N $dedup >> $OUT_DIR/run_scripts/${i}.${dedup}.bam_surgeon.sh

#     chmod +x $OUT_DIR/run_scripts/${i}.${dedup}.bam_surgeon.sh
# done
# wait

# parallel ::: $OUT_DIR/run_scripts/274042.${dedup}.bam_surgeon.sh $OUT_DIR/run_scripts/274046.${dedup}.bam_surgeon.sh
# wait

# #calculate coverage and stats
# for i in "${samples0[@]}"
# do
#     echo $i
#     LOG_FILE=$home_dir/data/results/${i}/preprocess_bam_${dedup}/${i}.qc.stdout.log
#     ERROR_FILE=$home_dir/data/results/${i}/preprocess_bam_${dedup}/${i}.qc.error.log

#     touch $OUT_DIR/run_scripts/${i}.${dedup}.qc.sh
#     echo '#!/bin/bash' > $OUT_DIR/run_scripts/${i}.${dedup}.qc.sh
#     echo $work_dir/prepare_bam/stats.sh $i $BED >> $OUT_DIR/run_scripts/${i}.${dedup}.qc.sh

#     chmod +x $OUT_DIR/run_scripts/${i}.${dedup}.qc.sh
#     $OUT_DIR/run_scripts/${i}.${dedup}.qc.sh 2>>$ERROR_FILE 1>>$LOG_FILE
# done
# wait

# ##############
# ##Train-Tests#
# ##############

# #Call variants
# SNV_truth=$home_dir/reference/bed/sides_twist/SNV_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
# Indel_truth=$home_dir/reference/bed/sides_twist/All_Indel_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
# for i in "${samples3[@]}"
# do
#     echo $i
#     touch $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
#     echo '#!/bin/bash' > $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
#     echo $work_dir/prepare_classifier/train_classifiers_twist_paired/run_pipeline_prepare_training_data.sh $i $ID_N $training $SNV_truth $Indel_truth $BED >> $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh

#     chmod +x $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
#     $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
# done
# wait

# for i in "${samples2[@]}"
# do
#     echo $i
#     SNV_truth=$home_dir/data/results/$i/truth_set/SNV_merge2.vcf.gz
#     Indel_truth=$home_dir/data/results/$i/truth_set/Indel_merge2.vcf.gz
#     touch $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
#     echo '#!/bin/bash' > $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
#     echo $work_dir/prepare_classifier/train_classifiers_twist_paired/run_pipeline_prepare_training_data.sh $i $ID_N $training $SNV_truth $Indel_truth $BED >> $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh

#     chmod +x $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
#     $OUT_DIR/run_scripts/${i}.${dedup}.call_variants_training.sh
# done
# wait

# #train_test_split_paired
# mkdir -p $home_dir/reference/somaticseq_training/$training/train_test_split_log
# LOG_FILE=$home_dir/reference/somaticseq_training/$training/train_test_split_log/stdout.log
# ERROR_FILE=$home_dir/reference/somaticseq_training/$training/train_test_split_log/error.log

# touch $OUT_DIR/run_scripts/${i}.${dedup}.train_test_split.sh
# echo '#!/bin/bash' > $OUT_DIR/run_scripts/${i}.${dedup}.train_test_split.sh
# echo $work_dir/prepare_classifier/train_test_split_paired/train_test_pipeline_for_training_set.sh $training >> $OUT_DIR/run_scripts/${i}.${dedup}.train_test_split.sh

# chmod +x $OUT_DIR/run_scripts/${i}.${dedup}.train_test_split.sh
# $OUT_DIR/run_scripts/${i}.${dedup}.train_test_split.sh 2>>$ERROR_FILE 1>>$LOG_FILE
# wait

#Generate final classifier
mkdir -p $home_dir/reference/somaticseq_training/$training/final_classifier_log
LOG_FILE=$home_dir/reference/somaticseq_training/$training/final_classifier_log/stdout.log
ERROR_FILE=$home_dir/reference/somaticseq_training/$training/final_classifier_log/error.log

touch $OUT_DIR/run_scripts/paired.${dedup}.final_classifier.sh
echo '#!/bin/bash' > $OUT_DIR/run_scripts/paired.${dedup}.final_classifier.sh
echo $work_dir/prepare_classifier/train_classifiers_twist_paired/train_somaticseq.sh $training 274040 274042 274044 274046 279690 classifier_${dedup} >> $OUT_DIR/run_scripts/paired.${dedup}.final_classifier.sh

chmod +x $OUT_DIR/run_scripts/paired.${dedup}.final_classifier.sh
$OUT_DIR/run_scripts/paired.${dedup}.final_classifier.sh 2>>$ERROR_FILE 1>>$LOG_FILE

# #Rename directories
# results=/home/iser/cfDNA_docker/data/results
# for i in "${samples0[@]}"
# do
#     mv $results/$i/bam_ready $results/$i/bam_ready_${dedup}
#     mv $results/$i/stats $results/$i/stats_${dedup}
#     mkdir $results/$i/stats
# done
# wait

# for i in "${samples2[@]}"
# do
#     mv $results/$i/trainingSet $results/$i/trainingSet_${dedup}
#     mv $results/$i/truth_set $results/$i/truth_set_${dedup}
# done
# wait