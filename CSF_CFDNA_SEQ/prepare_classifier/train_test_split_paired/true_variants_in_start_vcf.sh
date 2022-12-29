#!/bin/bash

#Input arguments
training=$1
ID=$2

#Directories
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/reference/somaticseq_training/$training
#OUT_DIR=$work_dir/$ID/true_variants_in_start_vcf
OUT_DIR=$work_dir/$ID/true_variants_in_start_vcf_bam_surgeon
mkdir -p $OUT_DIR

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
DICT=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.dict
#SNVs=$home_dir/reference/bed/sides_twist/SNV_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
#Indels=$home_dir/reference/bed/sides_twist/All_Indel_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
SNVs=/mnt/e/22-06-27_All_data_reference_sample_training/22.05-15_create_classifier_train_samples/22-06-30_DUPLEX/$ID/truth_set/synthetic_snvs.compatible.vcf.gz
Indels=/mnt/e/22-06-27_All_data_reference_sample_training/22.05-15_create_classifier_train_samples/22-06-30_DUPLEX/$ID/truth_set/synthetic_indels.leftAlign.compatible.vcf.gz


###SCRIPT###

#intersect raw snv/indel with truth set --> new truth set
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G broadinstitute/gatk \
gatk SortVcf \
-I $work_dir/$ID/tsv/Consensus.sSNV.vcf \
--SEQUENCE_DICTIONARY $DICT \
-O $OUT_DIR/Consensus.sSNV.sort.vcf
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G broadinstitute/gatk \
gatk SortVcf \
-I $work_dir/$ID/tsv/Consensus.sINDEL.vcf \
--SEQUENCE_DICTIONARY $DICT \
-O $OUT_DIR/Consensus.sINDEL.sort.vcf

raw_snv=$OUT_DIR/Consensus.sSNV.sort.vcf
raw_indel=$OUT_DIR/Consensus.sINDEL.sort.vcf

bgzip -c $raw_snv > ${raw_snv}.gz
tabix ${raw_snv}.gz
bgzip -c $raw_indel > ${raw_indel}.gz
tabix ${raw_indel}.gz

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 100G broadinstitute/gatk \
gatk CountVariants \
-V $raw_snv \
-O $OUT_DIR/Consensus.sSNV.sort.counts.txt

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 100G broadinstitute/gatk \
gatk CountVariants \
-V $raw_indel \
-O $OUT_DIR/Consensus.sINDEL.sort.counts.txt

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -v /mnt/e:/mnt/e -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $OUT_DIR/$ID/Truth_sets \
-O v \
$SNVs ${raw_snv}.gz"
mv $OUT_DIR/$ID/Truth_sets/0000.vcf $OUT_DIR/$ID/Truth_sets/SNV_truth_set.${ID}.vcf
mv $OUT_DIR/$ID/Truth_sets/sites.txt $OUT_DIR/$ID/Truth_sets/SNV_sites.${ID}.vcf
rm $OUT_DIR/$ID/Truth_sets/0001.vcf
bgzip -c $OUT_DIR/$ID/Truth_sets/SNV_truth_set.${ID}.vcf > $OUT_DIR/$ID/Truth_sets/SNV_truth_set.${ID}.vcf.gz
tabix $OUT_DIR/$ID/Truth_sets/SNV_truth_set.${ID}.vcf.gz

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -v /mnt/e:/mnt/e -u $UID --memory 200G 31071993/cfdna_pipeline_v2:pipeline_v2_train_test_split /bin/bash -c \
"bcftools isec \
-n~11 -c all \
-p $OUT_DIR/$ID/Truth_sets \
-O v \
$Indels ${raw_indel}.gz"
mv $OUT_DIR/$ID/Truth_sets/0000.vcf $OUT_DIR/$ID/Truth_sets/Indel_truth_set.${ID}.vcf
mv $OUT_DIR/$ID/Truth_sets/sites.txt $OUT_DIR/$ID/Truth_sets/INDEL_sites.${ID}.vcf
rm $OUT_DIR/$ID/Truth_sets/0001.vcf
bgzip -c $OUT_DIR/$ID/Truth_sets/Indel_truth_set.${ID}.vcf > $OUT_DIR/$ID/Truth_sets/Indel_truth_set.${ID}.vcf.gz
tabix $OUT_DIR/$ID/Truth_sets/Indel_truth_set.${ID}.vcf.gz
