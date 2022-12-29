#!/bin/bash

ID=$1
BED=$2
DEDUP=$3
home_dir=$4

#Directories
work_dir=$home_dir/data/results/${ID}
IN_DIR=$work_dir/bam
OUT_DIR=$work_dir/bam_ready
mkdir -p $OUT_DIR

#Resources
CReaK=$home_dir/software/agent3.0/agent3.0/lib/creak-1.0.5.jar
REFERENCE=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.fasta
dbSNP=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf
INDELS=$home_dir/reference/hg38/v0/Homo_sapiens_assembly38.known_indels.vcf.gz
MILLS=$home_dir/reference/hg38/v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz

#CReaK
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 500G 31071993/cfdna_pipeline_v2:agent_pipeline_v2 /bin/bash -c \
"java -Xmx240G -jar $CReaK \
-r -c $DEDUP -d 0 -f -mm 25 -mr 30 -F -MS 1 -MD 2 \
-b $BED -o $OUT_DIR/${ID}.aligned.deduped.1.bam \
$IN_DIR/${ID}.aligned.bam"

#Perform Base Quality Score Recalibration
docker run --rm -v ${home_dir}:${home_dir} --memory 200G broadinstitute/gatk \
gatk BQSRPipelineSpark \
-R $REFERENCE \
-I $OUT_DIR/${ID}.aligned.deduped.1.bam \
--known-sites $dbSNP \
--known-sites $INDELS \
--known-sites $MILLS \
-O ${OUT_DIR}/${ID}.aligned.deduped.bam \
--static-quantized-quals 10 --static-quantized-quals 20 --static-quantized-quals 30 \
-L $BED

docker run --rm -v ${home_dir}:${home_dir} --memory 100G 31071993/cfdna_pipeline_v2:pipeline_v2_bwa_mem2 /bin/bash -c \
"rm $IN_DIR/${ID}.aligned.bam && rm $OUT_DIR/${ID}.aligned.deduped.1.ba*"