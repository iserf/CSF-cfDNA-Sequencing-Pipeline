#!/bin/bash

#Input arguments
ID_T=$1
BAM_T=$2
home_dir=$3
classifier=$4
BED=$5

#Directories
work_dir=$home_dir/data/results/${ID_T}/variants/somaticseq_single
OUT_DIR=$work_dir/classify_variants
mkdir -p $OUT_DIR

#Files
BAM_DIR=$home_dir/data/results/${ID_T}/bam_ready

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
classifier_SNV=$home_dir/reference/somaticseq_training/classifiers_in_use/${classifier}/*.SNV.classifier
classifier_INDEL=$home_dir/reference/somaticseq_training/classifiers_in_use/${classifier}/*.INDEL.classifier

#Single caller vcfs
mutect2=$work_dir/somaticseq_callers/MuTect2.vcf
varscan=$work_dir/somaticseq_callers/VarScan2.vcf
vardict=$work_dir/somaticseq_callers/VarDict.vcf
strelka=$work_dir/somaticseq_callers/Strelka/results/variants/variants.vcf.gz
scalpel=$work_dir/somaticseq_callers/Scalpel.vcf
lofreq=$work_dir/somaticseq_callers/LoFreq.vcf
octopus_snv=$work_dir/octopus/${ID_T}_octopus_calls.snv.vcf
octopus_indel=$work_dir/octopus/${ID_T}_octopus_calls.indel.vcf


##Script##

#SomaticSeq Prediction mode
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
"somaticseq_parallel.py \
--output-directory  $OUT_DIR \
--genome-reference  $REFERENCE \
--inclusion-region  $BED \
--pass-threshold 0.1 \
--lowqual-threshold 0.01 \
--algorithm         xgboost \
--threads           1 \
--classifier-snv $classifier_SNV \
--classifier-indel $classifier_INDEL \
single \
--bam-file    $BAM_DIR/$BAM_T \
--sample-name $ID_T \
--mutect2-vcf       $mutect2 \
--vardict-vcf       $vardict \
--varscan-vcf       $varscan \
--strelka-vcf       $strelka \
--scalpel-vcf $scalpel \
--lofreq-vcf $lofreq \
--arbitrary-snvs $octopus_snv \
--arbitrary-indels $octopus_indel"
#--pass-threshold 0.1

grep -v "REJECT" $OUT_DIR/SSeq.Classified.sSNV.vcf > $OUT_DIR/SSeq.Classified.sSNV.pass.vcf
grep -v "REJECT" $OUT_DIR/SSeq.Classified.sINDEL.vcf > $OUT_DIR/SSeq.Classified.sINDEL.pass.vcf