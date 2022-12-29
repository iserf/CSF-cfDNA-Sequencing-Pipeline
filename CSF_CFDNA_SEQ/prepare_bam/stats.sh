#!/bin/bash

#Input arguments
ID=$1
BED=$2
home_dir=$3

#Directories
work_dir=$home_dir/data/results/${ID}
OUT_DIR=$work_dir/stats
mkdir -p $OUT_DIR

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta

#Files
BAM_RAW=$work_dir/bam/${ID}.aligned.sort.bam
BAM_DEDUPED=$work_dir/bam_ready/${ID}.aligned.deduped.bam

##Script
docker run --rm -v ${home_dir}:${home_dir} --memory 40G broadinstitute/gatk \
gatk FlagStatSpark -I $BAM_RAW -O $OUT_DIR/${ID}.aligned.sort.flagstat.txt
wait

docker run --rm -v ${home_dir}:${home_dir} --memory 40G broadinstitute/gatk \
gatk FlagStatSpark -I $BAM_DEDUPED -O $OUT_DIR/${ID}.aligned.deduped.flagstat.txt
wait

docker run --rm -v ${home_dir}:${home_dir} --memory 40G broadinstitute/gatk \
gatk --java-options "-Xmx40g" CollectHsMetrics -I $BAM_DEDUPED -O $OUT_DIR/${ID}.aligned.deduped.hs_metrics.txt -R $REFERENCE -TI $BED -BI $BED
wait