#!/bin/bash

#Input arguments
ID_T=$1
ID_N=$2
BAM_T=$3
training=$4
SNVs=$5
Indels=$6
BED=$7

#Directories
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/reference/somaticseq_training/$training/${ID_T}
OUT_DIR=$work_dir/tsv
mkdir -p $OUT_DIR

#Files
BAM_DIR=$home_dir/data/results/${ID_T}/bam_ready
BAM_N=$home_dir/data/results/${ID_N}/bam_ready/${ID_N}.aligned.deduped.bam

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
#BED=$home_dir/reference/bed/NPHD2019A_Covered_hg38.bed
DATA_SOURCE=$home_dir/reference/funcotator_dat_source_in_use
dbSNP=$home_dir/reference/funcotator_dat_source_in_use/dbsnp/hg38/hg38_All_20180418.vcf.gz
#SNVs=$home_dir/data/results/${ID_T}/truth_set/SNV_merge2.vcf.gz
#Indels=$home_dir/data/results/${ID_T}/truth_set/Indel_merge2.vcf.gz
# SNVs=$home_dir/reference/bed/sides_twist/SNV_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
# Indels=$home_dir/reference/bed/sides_twist/All_Indel_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz

#Single caller vcfs
mutect2=$work_dir/somaticseq_callers/MuTect2.vcf
varscan_snv=$work_dir/somaticseq_callers/VarScan2.snp.vcf
varscan_indel=$work_dir/somaticseq_callers/VarScan2.indel.vcf
vardict=$work_dir/somaticseq_callers/VarDict.vcf
strelka_snv=$work_dir/somaticseq_callers/Strelka/results/variants/somatic.snvs.vcf.gz
strelka_indel=$work_dir/somaticseq_callers/Strelka/results/variants/somatic.indels.vcf.gz
scalpel=$work_dir/somaticseq_callers/Scalpel.vcf
lofreq_snv=$work_dir/somaticseq_callers/LoFreq.somatic_final.snvs.vcf.gz
lofreq_indel=$work_dir/somaticseq_callers/LoFreq.somatic_final.indels.vcf.gz
muse=$work_dir/somaticseq_callers/MuSE.vcf
octopus_snv=$work_dir/octopus/${ID_T}_octopus_calls.snv.vcf
octopus_indel=$work_dir/octopus/${ID_T}_octopus_calls.indel.vcf

##Script##
#SomaticSeq Training mode
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
"somaticseq_parallel.py \
--output-directory  $OUT_DIR \
--genome-reference  $REFERENCE \
--inclusion-region  $BED \
--algorithm         xgboost \
--threads           24 \
--somaticseq-train \
--truth-snv $SNVs \
--truth-indel $Indels \
paired \
--tumor-bam-file    $BAM_DIR/$BAM_T \
--normal-bam-file   $BAM_N \
--tumor-sample $ID_T \
--normal-sample $ID_N \
--mutect2-vcf       $mutect2 \
--vardict-vcf       $vardict \
--varscan-snv       $varscan_snv \
--varscan-indel     $varscan_indel \
--strelka-snv       $strelka_snv \
--strelka-indel     $strelka_indel \
--lofreq-snv       $lofreq_snv \
--lofreq-indel     $lofreq_indel \
--muse-vcf     $muse \
--scalpel-vcf $scalpel \
--arbitrary-snvs $octopus_snv \
--arbitrary-indels $octopus_indel"