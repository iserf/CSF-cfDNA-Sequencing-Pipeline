#!/bin/bash
training=$1

home_dir=/home/iser/cfDNA_docker
workdir=/home/iser/cfDNA_docker/pipeline_v2/prepare_classifier/train_test_split_paired

seeds=(42 117 67403 83926 4910296)
IDs=(274040 274042 274044 274046 279690)

#Split samples in 80:20 train test split: Do 5 times for reproducibility
$workdir/split_multiple_samples.sh $training
wait

#Train somatic seq classifier with 80% training data and classify 20% test samples with this classifier
$workdir/train_test_multiple_samples.sh $training
wait

#Find true variants in 20% test data for calculation of sensitivity and specificity
samples1=(274040 274044 279690)
samples2=(274042 274046)

SNV_truth=$home_dir/reference/bed/sides_twist/SNV_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
Indel_truth=$home_dir/reference/bed/sides_twist/All_Indel_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
for j in "${samples1[@]}"
do
    for i in "${seeds[@]}"
    do
       $workdir/test_truth_intersect.sh $training $i $j $SNV_truth $Indel_truth
       mv $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/Truth_sets $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/Truth_sets_twist
       mv $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/overlap_truth $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/overlap_truth_twist

    done
    mv $home_dir/reference/somaticseq_training/$training/${j}/overlap_single_callers $home_dir/reference/somaticseq_training/$training/${j}/overlap_single_callers_twist
done

for j in "${samples2[@]}"
do
    for i in "${seeds[@]}"
    do
       $workdir/test_truth_intersect.sh $training $i $j $SNV_truth $Indel_truth
       mv $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/Truth_sets $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/Truth_sets_twist
       mv $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/overlap_truth $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/overlap_truth_twist
    done
    mv $home_dir/reference/somaticseq_training/$training/${j}/overlap_single_callers $home_dir/reference/somaticseq_training/$training/${j}/overlap_single_callers_twist
done

for j in "${samples2[@]}"
do
    SNV_truth=$home_dir/data/results/$j/truth_set/SNV_merge2.vcf.gz
    Indel_truth=$home_dir/data/results/$j/truth_set/Indel_merge2.vcf.gz
    for i in "${seeds[@]}"
    do
       $workdir/test_truth_intersect.sh $training $i $j $SNV_truth $Indel_truth
       mv $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/Truth_sets $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/Truth_sets_merge
       mv $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/overlap_truth $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/overlap_truth_merge
    done
    mv $home_dir/reference/somaticseq_training/$training/${j}/overlap_single_callers $home_dir/reference/somaticseq_training/$training/${j}/overlap_single_callers_merge
done

for j in "${samples2[@]}"
do
    SNV_truth=$home_dir/data/results/$j/truth_set/synthetic_snvs.compatible.vcf.gz
    Indel_truth=$home_dir/data/results/$j/truth_set/synthetic_indels.leftAlign.compatible.vcf.gz
    for i in "${seeds[@]}"
    do
       $workdir/test_truth_intersect.sh $training $i $j $SNV_truth $Indel_truth
       mv $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/Truth_sets $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/Truth_sets_bam_surgeon
       mv $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/overlap_truth $home_dir/reference/somaticseq_training/$training/classifiers/$i/test/$j/overlap_truth_bam_surgeon
    done
    mv $home_dir/reference/somaticseq_training/$training/${j}/overlap_single_callers $home_dir/reference/somaticseq_training/$training/${j}/overlap_single_callers_bam_surgeon
done

#write to file
mkdir -p /home/iser/cfDNA_docker/reference/somaticseq_training/$training/report

touch /home/iser/cfDNA_docker/reference/somaticseq_training/$training/report/report.twist.txt
echo -e Training'\t'ID'\t'Seed'\t'SNV_truth_set'\t'SNV_total'\t'SNV_overlap'\t'Sensitivity_SNV'\t'Specificity_SNV'\t'Indel_truth_set'\t'Indel_total'\t'Indel_overlap'\t'Sensitivity_Indel'\t'Specificity_Indel \
>> /home/iser/cfDNA_docker/reference/somaticseq_training/$training/report/report.twist.txt
for j in "${IDs[@]}"
do
    for i in "${seeds[@]}"
    do
       $workdir/write_to_file.sh $training $i $j Truth_sets_twist overlap_truth_twist twist
    done
done

touch /home/iser/cfDNA_docker/reference/somaticseq_training/$training/report/report.merge.txt
echo -e Training'\t'ID'\t'Seed'\t'SNV_truth_set'\t'SNV_total'\t'SNV_overlap'\t'Sensitivity_SNV'\t'Specificity_SNV'\t'Indel_truth_set'\t'Indel_total'\t'Indel_overlap'\t'Sensitivity_Indel'\t'Specificity_Indel \
>> /home/iser/cfDNA_docker/reference/somaticseq_training/$training/report/report.merge.txt
for j in "${samples2[@]}"
do
    for i in "${seeds[@]}"
    do
       $workdir/write_to_file.sh $training $i $j Truth_sets_merge overlap_truth_merge merge
    done
done

touch /home/iser/cfDNA_docker/reference/somaticseq_training/$training/report/report.bam_surgeon.txt
echo -e Training'\t'ID'\t'Seed'\t'SNV_truth_set'\t'SNV_total'\t'SNV_overlap'\t'Sensitivity_SNV'\t'Specificity_SNV'\t'Indel_truth_set'\t'Indel_total'\t'Indel_overlap'\t'Sensitivity_Indel'\t'Specificity_Indel \
>> /home/iser/cfDNA_docker/reference/somaticseq_training/$training/report/report.bam_surgeon.txt
for j in "${samples2[@]}"
do
    for i in "${seeds[@]}"
    do
       $workdir/write_to_file.sh $training $i $j Truth_sets_bam_surgeon overlap_truth_bam_surgeon bam_surgeon
    done
done

#writre single callers overlap to file
touch /home/iser/cfDNA_docker/reference/somaticseq_training/$training/report/report.single_callers.txt
echo -e Training'\t'ID'\t'Caller_file'\t'Mode'\t'SNV_found'\t'Indel_found'\t'Variants_found'\t'SNV_total'\t'indel_total'\t'total_variants'\t'sensitivity'\t'specificity >> /home/iser/cfDNA_docker/reference/somaticseq_training/$training/report/report.single_callers.txt

SNV_truth=$home_dir/reference/bed/sides_twist/SNV_truth_set.leftalignedtrimmed.NPHD2019A.vcf
Indel_truth=$home_dir/reference/bed/sides_twist/All_Indel_truth_set.leftalignedtrimmed.NPHD2019A.vcf
for j in "${IDs[@]}"
do
   $workdir/write_to_file_single_callers.sh $training $j twist $SNV_truth $Indel_truth
done


for j in "${samples2[@]}"
do
   SNV_truth=$home_dir/data/results/$j/truth_set/SNV_merge2.vcf
   Indel_truth=$home_dir/data/results/$j/truth_set/Indel_merge2.vcf
   $workdir/write_to_file_single_callers.sh $training $j merge $SNV_truth $Indel_truth
done

for j in "${samples2[@]}"
do
   SNV_truth=$home_dir/data/results/$j/truth_set/synthetic_snvs.compatible.vcf
   Indel_truth=$home_dir/data/results/$j/truth_set/synthetic_indels.leftAlign.compatible.vcf
   $workdir/write_to_file_single_callers.sh $training $j bam_surgeon $SNV_truth $Indel_truth
done