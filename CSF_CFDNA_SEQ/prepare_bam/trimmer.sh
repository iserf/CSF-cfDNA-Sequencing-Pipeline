#!/bin/bash

ID=$1
BED=$2
home_dir=$3

#Directories
work_dir=$home_dir/data/results/${ID}
OUT_DIR=$work_dir/fastq

#Resources
TRIMMER=$home_dir/software/agent3.0/agent3.0/lib/trimmer-3.0.3.jar

#trimmer
docker run --rm -v ${home_dir}:${home_dir} -u $UID --memory 100G 31071993/cfdna_pipeline_v2:agent_pipeline_v2 /bin/bash -c \
"java -Xmx100G -jar $TRIMMER \
-fq1 ${OUT_DIR}/${ID}*R1*fastq.gz \
-fq2 ${OUT_DIR}/${ID}*R2*fastq.gz \
-v2 \
-out_loc $OUT_DIR"

