#!/bin/bash

mnt=$1
LIBRARY=$2
RUN_NAME=$3

IN_DIR=$mnt/$LIBRARY/$RUN_NAME
OUT_DIR=$mnt/$LIBRARY/fastq
SAMPLE_SHEET=$mnt/$LIBRARY/$RUN_NAME/SampleSheet.csv
mkdir -p $OUT_DIR

##Scripts
docker run --memory 200G --rm -v ${mnt}:${mnt} 31071993/cfdna_pipeline_v2:pipeline_v2_bcl_convert2 /bin/bash -c \
"bcl-convert --bcl-input-directory $IN_DIR --output-directory $OUT_DIR --sample-sheet $SAMPLE_SHEET --no-lane-splitting true --force"

