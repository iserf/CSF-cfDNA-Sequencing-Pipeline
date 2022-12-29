#!/bin/bash

#Input arguments
ID_T=$1
BAM_T=$2
home_dir=$3
BED=$4

#Directories
work_dir=$home_dir/data/results/${ID_T}/variants/somaticseq_single
OUT_DIR=$work_dir/octopus
mkdir -p $OUT_DIR

#Files
BAM_DIR=$home_dir/data/results/${ID_T}/bam_ready

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta

##Script##
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 200G dancooke/octopus \
--threads \
-X 200GB -B 24GB \
-R $REFERENCE \
--regions-file $BED \
--bad-region-tolerance LOW \
-I $BAM_DIR/$BAM_T \
-C cancer \
--allow-octopus-duplicates \
--disable-downsampling \
--min-candidate-credible-vaf-probability 0.5 \
--min-somatic-posterior 1.0 \
--min-expected-somatic-frequency 0.0025 \
--min-credible-somatic-frequency 0.0025 \
--min-supporting-reads 2 \
--normal-contamination-risk LOW \
--output $OUT_DIR/${ID_T}_octopus_calls.vcf \
--sequence-error-model PCR.NOVASEQ \
--bamout $OUT_DIR/${ID_T}_octopus_calls.realigned.bam \
--somatic-forest /opt/octopus/resources/forests/somatic.v0.7.4.forest \
--keep-unfiltered-calls \
-w $OUT_DIR \
--max-haplotypes 100 \
--somatics-only
wait

docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
"splitVcf.py \
-infile $OUT_DIR/${ID_T}_octopus_calls.vcf \
-snv $OUT_DIR/${ID_T}_octopus_calls.snv.vcf \
-indel $OUT_DIR/${ID_T}_octopus_calls.indel.vcf"
