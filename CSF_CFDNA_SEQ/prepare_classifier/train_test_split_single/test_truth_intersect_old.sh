#!/bin/bash

#Input arguments
training=$1
seed=$2
ID=$3

#Directories
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/reference/somaticseq_training/$training
OUT_DIR=$work_dir/classifiers/$seed
mkdir -p $OUT_DIR

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
#SNVs=$home_dir/reference/bed/sides_twist/SNV_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
#Indels=$home_dir/reference/bed/sides_twist/All_Indel_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
#SNVs=$home_dir/data/results/$ID/truth_set/SNV_merge2.vcf.gz
#Indels=$home_dir/data/results/$ID/truth_set/Indel_merge2.vcf.gz
SNVs=$home_dir/data/results/$ID/truth_set/synthetic_snvs.compatible.vcf.gz
Indels=$home_dir/data/results/$ID/truth_set/synthetic_indels.compatible.vcf.gz
DICT=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.dict

###SCRIPT###

#intersect raw snv/indel with truth set --> new truth set
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G broadinstitute/gatk \
gatk SortVcf \
-I $OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.vcf \
--SEQUENCE_DICTIONARY $DICT \
-O $OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.sort.vcf
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G broadinstitute/gatk \
gatk SortVcf \
-I $OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.vcf \
--SEQUENCE_DICTIONARY $DICT \
-O $OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.sort.vcf

raw_snv=$OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.sort.vcf
raw_indel=$OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.sort.vcf

bgzip -c $raw_snv > ${raw_snv}.gz
tabix ${raw_snv}.gz
bgzip -c $raw_indel > ${raw_indel}.gz
tabix ${raw_indel}.gz

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $OUT_DIR/test/$ID/Truth_sets \
-O v \
$SNVs ${raw_snv}.gz"
mv $OUT_DIR/test/$ID/Truth_sets/0000.vcf $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf
bgzip -c $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf > $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf.gz
tabix $OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf.gz

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $OUT_DIR/test/$ID/Truth_sets \
-O v \
$Indels ${raw_indel}.gz"
mv $OUT_DIR/test/$ID/Truth_sets/0000.vcf $OUT_DIR/test/$ID/Truth_sets/Indel_truth_set.${ID}.${seed}.vcf
rm $OUT_DIR/test/$ID/Truth_sets/0001.vcf
bgzip -c $OUT_DIR/test/$ID/Truth_sets/Indel_truth_set.${ID}.${seed}.vcf > $OUT_DIR/test/$ID/Truth_sets/Indel_truth_set.${ID}.${seed}.vcf.gz
tabix $OUT_DIR/test/$ID/Truth_sets/Indel_truth_set.${ID}.${seed}.vcf.gz


#intersect classified variants with new truth set
grep -v "REJECT" $raw_snv > $OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.pass.vcf
bgzip -c $OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.pass.vcf > $OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.pass.vcf.gz
tabix $OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.pass.vcf.gz

grep -v "REJECT" $raw_indel > $OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.pass.vcf
bgzip -c $OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.pass.vcf > $OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.pass.vcf.gz
tabix $OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.pass.vcf.gz

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $OUT_DIR/test/$ID/overlap_truth/SNV \
-O v \
$OUT_DIR/test/$ID/Truth_sets/SNV_truth_set.${ID}.${seed}.vcf.gz \
$OUT_DIR/test/$ID/Ensemble.sSNV.${seed}.test.predicted.pass.vcf.gz"

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $OUT_DIR/test/$ID/overlap_truth/Indel \
-O v \
$OUT_DIR/test/$ID/Truth_sets/Indel_truth_set.${ID}.${seed}.vcf.gz \
$OUT_DIR/test/$ID/Ensemble.sINDEL.${seed}.test.predicted.pass.vcf.gz"