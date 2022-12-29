#!/bin/bash

#Input arguments
ID=$1
home_dir=$2

#Directories
work_dir=$home_dir/data/results/${ID}
OUT_DIR=$work_dir/fastqc
mkdir -p $OUT_DIR

#Files
FASTQ_TRIM_R1=$work_dir/fastq/${ID}*R1*Cut*fastq.gz
FASTQ_TRIM_R2=$work_dir/fastq/${ID}*R2*Cut*fastq.gz
BAM_RAW=$work_dir/bam/${ID}.aligned.sort.bam
BAM_DEDUPED=$work_dir/bam_ready/${ID}.aligned.deduped.bam

##Scripts
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 40G staphb/fastqc:latest /bin/bash -c \
"fastqc $FASTQ_TRIM_R1"

docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 40G staphb/fastqc:latest /bin/bash -c \
"fastqc $FASTQ_TRIM_R2"

docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 40G staphb/fastqc:latest /bin/bash -c \
"fastqc $BAM_RAW"

docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 40G staphb/fastqc:latest /bin/bash -c \
"fastqc $BAM_DEDUPED"
  
# copy all fastqc files to directory /fastqc    
find $work_dir/fastq/ -name '*fastqc.*' | xargs -I '{}' mv '{}' $OUT_DIR
find $work_dir/bam/ -name '*fastqc.*' | xargs -I '{}' mv '{}' $OUT_DIR
find $work_dir/bam_ready/ -name '*fastqc.*' | xargs -I '{}' mv '{}' $OUT_DIR

#perform multiqc
docker run --name multiqc_$ID --rm \
--mount type=bind,source=${home_dir}/data/results/${ID}/fastqc,target=/multiqc -w /multiqc \
ewels/multiqc

