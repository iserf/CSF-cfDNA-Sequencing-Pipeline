#!/bin/bash

ID_T=$1
home_dir=$2
Single_mode=$3

work_dir=$home_dir/data/results/${ID_T}
report=$work_dir/variants/somaticse*/report/${ID_T}.pipeline_v2.report.xlsx
stats=$work_dir/stats/${ID_T}.aligned.deduped.hs_metrics.txt
outfile=$work_dir/variants/somaticseq${Single_mode}/report/${ID_T}.oncoprint.xlsx

docker run --rm -v ${home_dir}:/home/iser/cfDNA_docker -v /mnt/h:/mnt/h -u $UID --memory 20G 31071993/cfdna_pipeline_v2:pipeline_v2_oncoprint /bin/bash -c \
"python oncoprint.py $ID_T $report $stats $outfile"