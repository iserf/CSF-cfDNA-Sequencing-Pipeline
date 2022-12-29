#!/bin/bash

test_vcf=$1
OUT_DIR=$2

#Directories
home_dir=/home/iser/cfDNA_docker
mkdir -p $OUT_DIR

#truth set
All_sides=$home_dir/reference/bed/sides_twist/All_sides_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
# SNVs=/mydata/data/results/274046S/truth_set/SNV_merge2.vcf.gz
# Indels=/mydata/data/results/274046S/truth_set/Indel_merge2.vcf.gz
SNVs=$home_dir/reference/bed/sides_twist/SNV_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
Indels=$home_dir/reference/bed/sides_twist/All_Indel_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz

#Ressources
REFERENCE=$home_dir/reference/hg38/v0/
BED=$home_dir/reference/bed/NPHD2019A_Covered_hg38.bed
DATA_SOURCE=$home_dir/reference/funcotator_dat_source_in_use

###SCRIPT###
bgzip -c $test_vcf > ${test_vcf}.gz
tabix ${test_vcf}.gz
#gunzip -k ${test_vcf}.gz

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $OUT_DIR/All_sides_intersect_Twist \
-O v \
$All_sides ${test_vcf}.gz"
mv $OUT_DIR/All_sides_intersect_Twist/0000.vcf $OUT_DIR/All_sides_intersect_Twist/All_sides_Twist.vcf
mv $OUT_DIR/All_sides_intersect_Twist/0001.vcf $OUT_DIR/All_sides_intersect_Twist/All_sides_query.vcf

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $OUT_DIR/SNVs_intersect_Twist \
-O v \
$SNVs ${test_vcf}.gz"
mv $OUT_DIR/SNVs_intersect_Twist/0000.vcf $OUT_DIR/SNVs_intersect_Twist/SNVs_Twist.vcf
mv $OUT_DIR/SNVs_intersect_Twist/0001.vcf $OUT_DIR/SNVs_intersect_Twist/SNVs_query.vcf

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $OUT_DIR/Indels_intersect_Twist \
-O v \
$Indels ${test_vcf}.gz"
mv $OUT_DIR/Indels_intersect_Twist/0000.vcf $OUT_DIR/Indels_intersect_Twist/Indels_Twist.vcf
mv $OUT_DIR/Indels_intersect_Twist/0001.vcf $OUT_DIR/Indels_intersect_Twist/Indels_query.vcf