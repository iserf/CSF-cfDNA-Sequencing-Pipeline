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
varscan_snv=VarScan2.snp.vcf
varscan_indel=VarScan2.indel.vcf
vardict=VarDict.vcf
strelka_snv=$variant_dir/somaticseq_callers/Strelka/results/variants/somatic.snvs.vcf.gz
strelka_indel=$variant_dir/somaticseq_callers/Strelka/results/variants/somatic.indels.vcf.gz
scalpel=Scalpel.vcf
lofreq_snv=$variant_dir/somaticseq_callers/LoFreq.somatic_final.snvs.vcf.gz
lofreq_indel=$variant_dir/somaticseq_callers/LoFreq.somatic_final.indels.vcf.gz
muse=MuSE.vcf
octopus_snv=$variant_dir/octopus/${ID}_octopus_calls.snv.vcf
octopus_indel=$variant_dir/octopus/${ID}_octopus_calls.indel.vcf

strelka_snv2=$variant_dir/somaticseq_callers/Strelka/results/variants/somatic.snvs.vcf
strelka_indel2=$variant_dir/somaticseq_callers/Strelka/results/variants/somatic.indels.vcf
lofreq_snv2=LoFreq.somatic_final.snvs.vcf
lofreq_indel2=LoFreq.somatic_final.indels.vcf

snv_single=($mutect2 $varscan_snv $vardict $muse $lofreq_snv2 )
indel_single=($mutect2 $varscan_indel $vardict $scalpel $lofreq_indel2)

Indel_truth_set="$(grep ^[^#] $Indels | wc -l)"
SNV_truth_set="$(grep ^[^#] $SNVs | wc -l)"
Truth_set=$(awk "BEGIN {print $Indel_truth_set+$SNV_truth_set}")

#Mutect2
i=$mutect2
SNV_found="$(grep ^[^#] $work_dir/SNVs/${i}.gz.shared_truth.txt | wc -l)"
Indel_found="$(grep ^[^#] $work_dir/Indels/${i}.gz.shared_truth.txt | wc -l)"
Variants_found=$(awk "BEGIN {print $SNV_found+$Indel_found}")
SNV_total="NA"
indel_total="NA"
total_variants="$(grep ^[^#] $variant_dir/somaticseq_callers/$i | wc -l)"
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'Mutect2'\t'$mode'\t'$SNV_found'\t'$Indel_found'\t'$Variants_found'\t'$SNV_total'\t'$indel_total'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt

#Varscan
i=$varscan_snv
j=$varscan_indel
SNV_found="$(grep ^[^#] $work_dir/SNVs/${i}.gz.shared_truth.txt | wc -l)"
Indel_found="$(grep ^[^#] $work_dir/Indels/${j}.gz.shared_truth.txt | wc -l)"
Variants_found=$(awk "BEGIN {print $SNV_found+$Indel_found}")
SNV_total="$(grep ^[^#] $variant_dir/somaticseq_callers/$i | wc -l)"
indel_total="$(grep ^[^#] $variant_dir/somaticseq_callers/$j | wc -l)"
total_variants=$(awk "BEGIN {print $SNV_total+$indel_total}")
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'VarScan2'\t'$mode'\t'$SNV_found'\t'$Indel_found'\t'$Variants_found'\t'$SNV_total'\t'$indel_total'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt

#Vardict
i=$vardict
SNV_found="$(grep ^[^#] $work_dir/SNVs/${i}.gz.shared_truth.txt | wc -l)"
Indel_found="$(grep ^[^#] $work_dir/Indels/${i}.gz.shared_truth.txt | wc -l)"
Variants_found=$(awk "BEGIN {print $SNV_found+$Indel_found}")
SNV_total="NA"
indel_total="NA"
total_variants="$(grep ^[^#] $variant_dir/somaticseq_callers/$i | wc -l)"
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'VarDict'\t'$mode'\t'$SNV_found'\t'$Indel_found'\t'$Variants_found'\t'$SNV_total'\t'$indel_total'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt

#Strelka
i=$strelka_snv2
j=$strelka_indel2
SNV_found="$(grep ^[^#] $work_dir/SNVs/Strelka.shared_truth.txt | wc -l)"
Indel_found="$(grep ^[^#] $work_dir/Indels/Strelka.shared_truth.txt | wc -l)"
Variants_found=$(awk "BEGIN {print $SNV_found+$Indel_found}")
SNV_total="$(grep ^[^#] $i | wc -l)"
indel_total="$(grep ^[^#] $j | wc -l)"
total_variants=$(awk "BEGIN {print $SNV_total+$indel_total}")
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'Strelka'\t'$mode'\t'$SNV_found'\t'$Indel_found'\t'$Variants_found'\t'$SNV_total'\t'$indel_total'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt

#LoFreq
i=$lofreq_snv2
j=$lofreq_indel2
SNV_found="$(grep ^[^#] $work_dir/SNVs/${i}.gz.shared_truth.txt | wc -l)"
Indel_found="$(grep ^[^#] $work_dir/Indels/${j}.gz.shared_truth.txt | wc -l)"
Variants_found=$(awk "BEGIN {print $SNV_found+$Indel_found}")
SNV_total="$(grep ^[^#] $variant_dir/somaticseq_callers/$i | wc -l)"
indel_total="$(grep ^[^#] $variant_dir/somaticseq_callers/$j | wc -l)"
total_variants=$(awk "BEGIN {print $SNV_total+$indel_total}")
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'LoFreq'\t'$mode'\t'$SNV_found'\t'$Indel_found'\t'$Variants_found'\t'$SNV_total'\t'$indel_total'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt

#Octopus
i=$octopus_snv
j=$octopus_indel
SNV_found="$(grep ^[^#] $work_dir/SNVs/Octopus.shared_truth.txt | wc -l)"
Indel_found="$(grep ^[^#] $work_dir/Indels/Octopus.shared_truth.txt | wc -l)"
Variants_found=$(awk "BEGIN {print $SNV_found+$Indel_found}")
SNV_total="$(grep ^[^#] $i | wc -l)"
indel_total="$(grep ^[^#] $j | wc -l)"
total_variants=$(awk "BEGIN {print $SNV_total+$indel_total}")
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'Octopus'\t'$mode'\t'$SNV_found'\t'$Indel_found'\t'$Variants_found'\t'$SNV_total'\t'$indel_total'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt

#MuSE
i=$muse
SNV_found="$(grep ^[^#] $work_dir/SNVs/${i}.gz.shared_truth.txt | wc -l)"
Indel_found="NA"
Variants_found=$SNV_found
SNV_total="$(grep ^[^#] $variant_dir/somaticseq_callers/$i | wc -l)"
indel_total="NA"
total_variants=$SNV_total
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'MuSE'\t'$mode'\t'$SNV_found'\t'$Indel_found'\t'$Variants_found'\t'$SNV_total'\t'$indel_total'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt

#Scalpel 
i=$scalpel
SNV_found="NA"
Indel_found="$(grep ^[^#] $work_dir/Indels/${i}.gz.shared_truth.txt | wc -l)"
Variants_found=$Indel_found
SNV_total="NA"
indel_total="$(grep ^[^#] $variant_dir/somaticseq_callers/$i | wc -l)"
total_variants=$indel_total
sensitivity=$(awk "BEGIN {print $Variants_found/$Truth_set}")
specificity=$(awk "BEGIN {print $Variants_found/$total_variants}")
echo -e $training'\t'$ID'\t'Scalpel'\t'$mode'\t'$SNV_found'\t'$Indel_found'\t'$Variants_found'\t'$SNV_total'\t'$indel_total'\t'$total_variants'\t'$sensitivity'\t'$specificity >> $OUT_DIR/report.single_callers.txt