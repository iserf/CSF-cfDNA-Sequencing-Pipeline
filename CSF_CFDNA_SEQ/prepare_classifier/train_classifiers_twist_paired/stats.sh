#!/bin/bash

#Directories
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/data/plot_data/ref_standards/22-07-04
OUT_DIR=$work_dir/Coverage_ref_samples_paired
mkdir -p $OUT_DIR

mnt=/mnt/e
storage_drive1=${mnt}/22-06-27_All_data_reference_sample_training/22.05-15_create_classifier_train_samples



#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
BED=$home_dir/reference/bed/NPHD2019A_Covered_hg38.interval_list

#Files

IDs=(274040 274042 274044 274046 279690)

BAM_RAW=$work_dir/bam/${ID}.aligned.sort.bam
BAM_DEDUPED=$work_dir/bam_ready/${ID}.aligned.deduped.bam

##Scripts

DEDUP=DUPLEX
mkdir $OUT_DIR/$DEDUP

for i in "${IDs[@]}"
do
    docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -v ${mnt}:/mnt/e --memory 40G broadinstitute/gatk \
    gatk --java-options "-Xmx40g" CollectHsMetrics -I $home_dir/data/results/$i/bam_ready/${i}.aligned.deduped.bam -O $OUT_DIR/$DEDUP/${i}.aligned.deduped.hs_metrics.txt -R $REFERENCE -TI $BED -BI $BED
done
wait

# sample=22-07-10_SINGLE
# DEDUP=SINGLE
# mkdir $OUT_DIR/$DEDUP

# for i in "${IDs[@]}"
# do
#     docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -v ${mnt}:/mnt/e --memory 40G broadinstitute/gatk \
#     gatk --java-options "-Xmx40g" CollectHsMetrics -I $storage_drive1/$sample/$i/bam_ready_${DEDUP}/${i}.aligned.deduped.bam -O $OUT_DIR/$DEDUP/${i}.aligned.deduped.hs_metrics.txt -R $REFERENCE -TI $BED -BI $BED
# done
# wait

# sample=22-07-03_HYBRID
# DEDUP=HYBRID
# mkdir $OUT_DIR/$DEDUP

# for i in "${IDs[@]}"
# do
#     docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -v ${mnt}:/mnt/e --memory 40G broadinstitute/gatk \
#     gatk --java-options "-Xmx40g" CollectHsMetrics -I $storage_drive1/$sample/$i/bam_ready_${DEDUP}/${i}.aligned.deduped.bam -O $OUT_DIR/$DEDUP/${i}.aligned.deduped.hs_metrics.txt -R $REFERENCE -TI $BED -BI $BED
# done
# wait

# DEDUP=markduplicates
# mkdir $OUT_DIR/$DEDUP

# for i in "${IDs[@]}"
# do
#     cp $storage_drive1/$i/stats_${DEDUP}/${i}.aligned.deduped.hs_metrics.txt $OUT_DIR/$DEDUP
# done
