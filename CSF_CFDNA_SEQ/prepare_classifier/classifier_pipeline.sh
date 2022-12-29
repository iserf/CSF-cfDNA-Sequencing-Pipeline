#!/bin/bash
home_dir=/home/iser/cfDNA_docker
work_dir=$home_dir/pipeline_v2/prepare_classifier

# 1. Generate fastq with bcl-convert for Libraries L0942 and L0991

# 2. Copy R1/R2 fastq for samples 274040 274042 274044 274046 279690 and 279692 into ubuntu file system
# samples2=(274040 274042 274044 274046)
# samples1=(279690 279692)
# for i in "${samples2[@]}"
# do
#     cp -r $home_dir/data/results/ID $home_dir/data/results/$i
#     cp /mnt/f/Flo/L0942/fastq/${i}*.fastq.gz $home_dir/data/results/$i/fastq
# done
# wait

# for i in "${samples1[@]}"
# do
#     cp -r $home_dir/data/results/ID $home_dir/data/results/$i
#     cp /mnt/e/L0991/fastq/${i}*.fastq.gz $home_dir/data/results/$i/fastq
# done
# wait

# 3. Prepare raw bam files for all samples and deduplicate normal sample 279692
# $work_dir/trim_align.sh
# wait

# 4. Train and test classifier for paired samples deduplicated by the indicated strategies
$work_dir/make_classifier.sh locatit_xthsv1
wait

# $work_dir/make_classifier.sh locatit_xthsv2
# wait

# $work_dir/make_classifier.sh markduplicates
