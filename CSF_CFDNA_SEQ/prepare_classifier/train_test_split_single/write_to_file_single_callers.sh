#!/bin/bash
training=$1
ID=$2
mode=$3
SNVs=$4
Indels=$5


#Directories
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/reference/somaticseq_training/$training/$ID/overlap_single_callers_${mode}
OUT_DIR=$home_dir/reference/somaticseq_training/$training/report
mkdir -p $OUT_DIR

#Single caller vcfs
variant_dir=$home_dir/reference/somaticseq_training/$training/${ID}

mutect2=MuTect2.vcf
varscan=VarScan2.vcf
vardict=VarDict.vcf
strelka=$variant_dir/somaticseq_callers/Strelka/results/variants/variants.vcf.gz
scalpel=Scalpel.vcf
lofreq=LoFreq.vcf
octopus=$variant_dir/octopus/${ID}_octopus_calls.vcf

gunzip -k $strelka
wait

strelka2=$variant_dir/somaticseq_callers/Strelka/results/variants/variants.vcf

Indel_truth_set="$(grep ^[^#] $Indels | wc -l)"
SNV_truth_set="$(grep ^[^#] $SNVs | wc -l)"
Truth_set=$(awk "BEGIN {print $Indel_truth_set+$SNV_truth_set}")

#Mutect2
i=$mutect2
Variants_found="$(grep ^[^#] $work_dir/${i}.gz.shared_truth.txt | wc -l)"
total_variants="$(grep ^[^#] $variant_dir/somaticseq_callers/$i | wc -l)"
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'Mutect2'\t'$mode'\t'$Variants_found'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt

#Varscan
i=$varscan
Variants_found="$(grep ^[^#] $work_dir/${i}.gz.shared_truth.txt | wc -l)"
total_variants="$(grep ^[^#] $variant_dir/somaticseq_callers/$i | wc -l)"
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'VarScan2'\t'$mode'\t'$Variants_found'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt

#Vardict
i=$vardict
Variants_found="$(grep ^[^#] $work_dir/${i}.gz.shared_truth.txt | wc -l)"
total_variants="$(grep ^[^#] $variant_dir/somaticseq_callers/$i | wc -l)"
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'VarDict'\t'$mode'\t'$Variants_found'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt

#Strelka
i=Strelka
Variants_found="$(grep ^[^#] $work_dir/${i}.shared_truth.txt | wc -l)"
total_variants="$(grep ^[^#] $strelka2 | wc -l)"
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'Strelka2'\t'$mode'\t'$Variants_found'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt

#LoFreq
i=$lofreq
Variants_found="$(grep ^[^#] $work_dir/${i}.gz.shared_truth.txt | wc -l)"
total_variants="$(grep ^[^#] $variant_dir/somaticseq_callers/$i | wc -l)"
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'LoFreq'\t'$mode'\t'$Variants_found'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt

#Octopus
i=Octopus
Variants_found="$(grep ^[^#] $work_dir/${i}.shared_truth.txt | wc -l)"
total_variants="$(grep ^[^#] $octopus | wc -l)"
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'Octopus'\t'$mode'\t'$Variants_found'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt

#Scalpel 
i=$scalpel
Variants_found="$(grep ^[^#] $work_dir/${i}.gz.shared_truth.txt | wc -l)"
total_variants="$(grep ^[^#] $variant_dir/somaticseq_callers/$i | wc -l)"
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'Scalpel'\t'$mode'\t'$Variants_found'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt
