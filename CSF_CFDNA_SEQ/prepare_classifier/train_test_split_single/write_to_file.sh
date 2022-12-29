#!/bin/bash
training=$1
seed=$2
ID=$3
Truth_sets=$4
overlap_truth=$5
mode=$6

#Directories
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/reference/somaticseq_training/$training/classifiers/$seed/test/$ID
OUT_DIR=$home_dir/reference/somaticseq_training/$training/report
mkdir -p $OUT_DIR

Indel_truth_set="$(grep ^[^#] $work_dir/$Truth_sets/Indel_truth_set.${ID}.${seed}.vcf | wc -l)"
Indel_found="$(grep ^[^#] $work_dir/$overlap_truth/Indel/sites.txt | wc -l)"
Indel_total="$(grep ^[^#] $work_dir/Ensemble.sINDEL.${seed}.test.predicted.pass.vcf | wc -l)"
SNV_truth_set="$(grep ^[^#] $work_dir/$Truth_sets/SNV_truth_set.${ID}.${seed}.vcf | wc -l)"
SNV_found="$(grep ^[^#] $work_dir/$overlap_truth/SNV/sites.txt | wc -l)"
SNV_total="$(grep ^[^#] $work_dir/Ensemble.sSNV.${seed}.test.predicted.pass.vcf | wc -l)"
sensitivity_SNV=$(awk "BEGIN {print $SNV_found/$SNV_truth_set}")
specificity_SNV=$(awk "BEGIN {print $SNV_found/$SNV_total}")
sensitivity_Indel=$(awk "BEGIN {print $Indel_found/$Indel_truth_set}")
specificity_Indel=$(awk "BEGIN {print $Indel_found/$Indel_total}")
echo -e $training'\t'$ID'\t'$seed'\t'$SNV_truth_set'\t'$SNV_total'\t'$SNV_found'\t'$sensitivity_SNV'\t'$specificity_SNV'\t'$Indel_truth_set'\t'$Indel_total'\t'$Indel_found'\t'$sensitivity_Indel'\t'$specificity_Indel >> $OUT_DIR/report.${mode}.txt

