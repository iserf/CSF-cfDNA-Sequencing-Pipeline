#!/bin/bash

#Input arguments
ID_T=$1
ID_N=$2
dedup=$3

#Directories
home_dir=/home/iser/cfDNA_docker
#work_dir=$home_dir/pipeline_v2/prepare_classifier/bam_surgeon
#cp -r $home_dir/data/results/ID $home_dir/data/results/${ID_T}v1
OUT_DIR=$home_dir/data/results/${ID_T}/trainingSet
mkdir -p $OUT_DIR

#Files
BAM_DIR=$home_dir/data/results/$ID_T/bam_ready
BAM_N=$home_dir/data/results/${ID_N}/bam_ready/${ID_N}.aligned.deduped.bam

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
BED=$home_dir/reference/bed/NPHD2019A_Covered_hg38.bed
DATA_SOURCE=$home_dir/reference/funcotator_dat_source_in_use
dbSNP=$home_dir/reference/funcotator_dat_source_in_use/dbsnp/hg38/hg38_All_20180418.vcf.gz
Twist_SNV=$home_dir/reference/bed/sides_twist/SNV_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
Twist_Indel=$home_dir/reference/bed/sides_twist/All_Indel_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz


##Script##

{

mv $BAM_DIR/${ID_T}.aligned.deduped.bai $BAM_DIR/${ID_T}.aligned.deduped.bam.bai

#Perform Bam Surgeon
docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 200G lethalfang/somaticseq:latest /bin/bash -c \
"/opt/somaticseq/somaticseq/utilities/dockered_pipelines/bamSimulator/BamSimulator_singleThread.sh \
--genome-reference  $REFERENCE \
--tumor-bam-in      $BAM_DIR/${ID_T}.aligned.deduped.bam \
--normal-bam-in      $BAM_N \
--tumor-bam-out     ${ID_T}.syntheticTumor.bam \
--normal-bam-out    ${ID_N}.syntheticNormal.bam \
--selector  $BED \
--min-variant-reads 2 \
--num-snvs 500 --num-indels 500 \
--min-vaf 0.05 --max-vaf 0.8 --left-beta 2 --right-beta 5 \
--output-dir        $OUT_DIR"

chmod +x $OUT_DIR/logs/*
wait
$OUT_DIR/logs/*.cmd

#Move Bam Files with Spiked in mutations into bam_ready directory
mv $BAM_DIR/${ID_T}.aligned.deduped.bam $BAM_DIR/${ID_T}.aligned.deduped.no_spike_in.bam
mv $BAM_DIR/${ID_T}.aligned.deduped*bai $BAM_DIR/${ID_T}.aligned.deduped.no_spike_in.bam.bai
mv $OUT_DIR/${ID_T}.syntheticTumor.bam $BAM_DIR/${ID_T}.aligned.deduped.bam
mv $OUT_DIR/${ID_T}.syntheticTumor.bam.bai $BAM_DIR/${ID_T}.aligned.deduped.bam.bai

#Generate new truth sets
mkdir $home_dir/data/results/$ID_T/truth_set

cp $OUT_DIR/synthetic_indels.leftAlign.vcf $home_dir/data/results/$ID_T/truth_set/synthetic_indels.leftAlign.vcf
cp $OUT_DIR/synthetic_snvs.vcf $home_dir/data/results/$ID_T/truth_set/synthetic_snvs.vcf

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 50G 31071993/cfdna_pipeline_v2:pipeline_v2_bam_surgeon /bin/bash -c \
"python modify_synthetic_vcf.py \
$home_dir/data/results/$ID_T/truth_set/synthetic_indels.leftAlign.vcf \
$home_dir/data/results/$ID_T/truth_set/synthetic_indels.leftAlign.compatible.vcf"

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 50G 31071993/cfdna_pipeline_v2:pipeline_v2_bam_surgeon /bin/bash -c \
"python modify_synthetic_vcf.py \
$home_dir/data/results/$ID_T/truth_set/synthetic_snvs.vcf \
$home_dir/data/results/$ID_T/truth_set/synthetic_snvs.compatible.vcf"

bgzip -c $home_dir/data/results/$ID_T/truth_set/synthetic_snvs.compatible.vcf > $home_dir/data/results/$ID_T/truth_set/synthetic_snvs.compatible.vcf.gz
tabix $home_dir/data/results/$ID_T/truth_set/synthetic_snvs.compatible.vcf.gz

bgzip -c $home_dir/data/results/$ID_T/truth_set/synthetic_indels.leftAlign.compatible.vcf > $home_dir/data/results/$ID_T/truth_set/synthetic_indels.leftAlign.compatible.vcf.gz
tabix $home_dir/data/results/$ID_T/truth_set/synthetic_indels.leftAlign.compatible.vcf.gz

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 50G 31071993/cfdna_pipeline_v2:pipeline_v2_bam_surgeon \
gatk MergeVcfs \
-I $home_dir/data/results/$ID_T/truth_set/synthetic_snvs.compatible.vcf.gz \
-I $Twist_SNV \
-D $home_dir/reference/hg38/v0/Homo_sapiens_assembly38.dict \
-O $home_dir/data/results/$ID_T/truth_set/SNV_merge2.vcf.gz

gunzip -k $home_dir/data/results/$ID_T/truth_set/SNV_merge2.vcf.gz

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -u $UID --memory 50G 31071993/cfdna_pipeline_v2:pipeline_v2_bam_surgeon \
gatk MergeVcfs \
-I $home_dir/data/results/$ID_T/truth_set/synthetic_indels.leftAlign.compatible.vcf.gz \
-I $Twist_Indel \
-D $home_dir/reference/hg38/v0/Homo_sapiens_assembly38.dict \
-O $home_dir/data/results/$ID_T/truth_set/Indel_merge2.vcf.gz

gunzip -k $home_dir/data/results/$ID_T/truth_set/Indel_merge2.vcf.gz

tabix $home_dir/data/results/$ID_T/truth_set/SNV_merge2.vcf.gz
tabix $home_dir/data/results/$ID_T/truth_set/Indel_merge2.vcf.gz

} 2>> $home_dir/data/results/${ID_T}/preprocess_bam_${dedup}/${ID_T}.bam_surgeon.stdout.log 1>> $home_dir/data/results/${ID_T}/preprocess_bam_${dedup}/${ID_T}.bam_surgeon.error.log

# /opt/somaticseq/somaticseq/utilities/dockered_pipelines/bamSimulator/BamSimulator_multiThreads.sh \
# --output-dir        $OUT_DIR/trainingSet \
# --genome-reference  $REFERENCE \
# --tumor-bam-in      $BAM_DIR/${ID_T}.aligned.deduped.bam \
# --tumor-bam-out     $OUT_DIR/syntheticTumor.bam \
# --normal-bam-out    $OUT_DIR/syntheticNormal.bam \
# --selector  $BED \
# --split-proportion  0.3 \
# --min-variant-reads 2 \
# --threads           1 \
# --num-snvs 200 --num-indels 200 --num-svs 0 \
# --min-vaf 0.2 --max-vaf 0.6 --left-beta 2 --right-beta 5 \
# --split-bam --indel-realign --merge-output-bams
# --action            qsub \

#parallel -j0 ::: 

# bcftools merge 
# --force-samples 
# -o /mydata/data/temp/test_vcf_merge.vcf -O v 
# /mydata/data/temp/synthetic_snvs.vcf.gz 
# /mydata/data/temp/SNV_truth_set.leftalignedtrimmed.NPHD2019A.vcf.gz
