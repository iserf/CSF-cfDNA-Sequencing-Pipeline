#!/bin/bash

ID=$1
home_dir=$2

#Directories
work_dir=$home_dir/data/results/${ID}
IN_DIR=$work_dir/fastq
OUT_DIR=$work_dir/bam
mkdir -p $OUT_DIR

#Resources
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
HEADER="@RG'\'tID:${ID}'\'tPL:ILLUMINA'\'tLB:SureSelectXTHSv2'\'tSM:${ID}"

##Scripts
docker run --memory 100G --rm -v ${home_dir}:${home_dir} 31071993/cfdna_pipeline_v2:pipeline_v2_bwa_mem2 /bin/bash -c \
"bwa-mem2 mem -t 22 -C \
-R ${HEADER} \
$REFERENCE \
${IN_DIR}/${ID}*R1*Cut*.fastq.gz \
${IN_DIR}/${ID}*R2*Cut*.fastq.gz \
| samtools view -b -h > ${OUT_DIR}/${ID}.aligned.bam"
wait

docker run --rm -v ${home_dir}:${home_dir} --memory 100G 31071993/cfdna_pipeline_v2:pipeline_v2_bwa_mem2 /bin/bash -c \
"samtools sort -@ 10 -o ${OUT_DIR}/${ID}.aligned.sort.bam -O BAM ${OUT_DIR}/${ID}.aligned.bam"
wait

docker run --rm -v ${home_dir}:${home_dir} --memory 100G 31071993/cfdna_pipeline_v2:pipeline_v2_bwa_mem2 /bin/bash -c \
"samtools index -b ${OUT_DIR}/${ID}.aligned.sort.bam"