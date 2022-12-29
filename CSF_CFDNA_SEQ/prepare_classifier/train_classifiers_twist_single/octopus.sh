#!/bin/bash

#Input arguments
ID_T=$1
BAM_T=$2
training=$3
BED=$4

#Directories
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/reference/somaticseq_training/$training/${ID_T}
OUT_DIR=$work_dir/octopus
mkdir -p $OUT_DIR

#Files
BAM_DIR=$home_dir/data/results/${ID_T}/bam_ready

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
#BED=$home_dir/reference/bed/NPHD2019A_Covered_hg38.bed
DATA_SOURCE=$home_dir/reference/funcotator_dat_source_in_use
dbSNP=$home_dir/reference/funcotator_dat_source_in_use/dbsnp/hg38/hg38_All_20180418.vcf.gz

##Script##
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 230G dancooke/octopus \
--threads \
-X 200GB -B 24GB \
-R $REFERENCE \
--regions-file $BED \
-I $BAM_DIR/$BAM_T \
-C cancer \
--allow-octopus-duplicates \
--disable-downsampling \
--min-candidate-credible-vaf-probability 0.5 \
--min-somatic-posterior 1.0 \
--min-expected-somatic-frequency 0.001 \
--min-credible-somatic-frequency 0.001 \
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

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
"splitVcf.py \
-infile $OUT_DIR/${ID_T}_octopus_calls.vcf \
-snv $OUT_DIR/${ID_T}_octopus_calls.snv.vcf \
-indel $OUT_DIR/${ID_T}_octopus_calls.indel.vcf"

#Zip & unzip files
octopus_snv=$work_dir/octopus/${ID_T}_octopus_calls.snv.vcf
octopus_indel=$work_dir/octopus/${ID_T}_octopus_calls.indel.vcf

zip=($octopus_snv $octopus_indel)
for i in "${zip[@]}"
do
    bgzip -c ${i} > ${i}.gz
    tabix ${i}.gz
done