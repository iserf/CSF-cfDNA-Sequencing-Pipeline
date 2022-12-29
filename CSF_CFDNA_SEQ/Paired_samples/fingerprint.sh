#!/bin/bash

#Input arguments
ID_T=$1
ID_N=$2
BAM_T=$3
home_dir=$4

#Directories
work_dir=$home_dir/data/results/${ID_T}/variants/somaticseq
OUT_DIR=$work_dir/fingerprint
mkdir -p $OUT_DIR

#Files
BAM_DIR=$home_dir/data/results/${ID_T}/bam_ready
BAM_N=$home_dir/data/results/${ID_N}/bam_ready/${ID_N}.aligned.deduped.bam

#Resources
MAP=$home_dir/reference/fingerprint/overlapSNP.ODCF.3.map

##CheckFingerprint (Picard) 
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 100G broadinstitute/gatk \
gatk CrosscheckFingerprints \
-I $BAM_DIR/$BAM_T \
-I $BAM_N \
--HAPLOTYPE_MAP $MAP \
--EXPECT_ALL_GROUPS_TO_MATCH true \
-O $OUT_DIR/${ID_T}_${ID_N}.crosscheck_metrics