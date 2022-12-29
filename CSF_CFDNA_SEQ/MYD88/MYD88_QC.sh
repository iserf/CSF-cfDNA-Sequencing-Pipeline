#!/bin/bash

#Input arguments
ID_T=$1
home_dir=$2
INTERVALS=$3

#Directories
work_dir=$home_dir/data/results/${ID_T}
OUT_DIR=$work_dir/MYD88_L265P
mkdir -p $OUT_DIR

#Files
BAM_raw=$home_dir/data/results/${ID_T}/bam/${ID_T}.aligned.sort.bam
BAM_dedup=$home_dir/data/results/${ID_T}/bam_ready/${ID_T}.aligned.deduped.bam

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
DATA_SOURCE=$home_dir/reference/funcotator_dat_source_in_use


##Script##

#Some more QC data
docker run --rm -v ${home_dir}:${home_dir} --memory 40G broadinstitute/gatk \
gatk --java-options "-Xmx40g" CollectHsMetrics -I $BAM_raw -O $OUT_DIR/${ID}.aligned.raw.hs_metrics.txt -R $REFERENCE -TI $INTERVALS -BI $INTERVALS

docker run --rm -v ${home_dir}:${home_dir} --memory 40G broadinstitute/gatk \
gatk CollectInsertSizeMetrics \
-I $BAM_raw \
-O  $OUT_DIR/${ID}.aligned.raw.insert_size_metrics.txt \
-H  $OUT_DIR/${ID}.aligned.raw.insert_size_histogram.pdf

docker run --rm -v ${home_dir}:${home_dir} --memory 40G broadinstitute/gatk \
gatk CollectInsertSizeMetrics \
-I $BAM_dedup \
-O  $OUT_DIR/${ID}.aligned.deduped.insert_size_metrics.txt \
-H  $OUT_DIR/${ID}.aligned.deduped.insert_size_histogram.pdf