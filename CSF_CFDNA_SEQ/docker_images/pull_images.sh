#!/bin/bash

#install GNU parallel

docker pull 31071993/cfdna_pipeline_v2:agent_pipeline_v2
wait
docker pull 31071993/cfdna_pipeline_v2:pipeline_v2_bcl_convert2
wait
docker pull 31071993/cfdna_pipeline_v2:pipeline_v2_bwa_mem2
wait
docker pull 31071993/cfdna_pipeline_v2:pipeline_v2_report
wait
docker pull 31071993/cfdna_pipeline_v2:pipeline_v2_special
wait
docker pull broadinstitute/gatk
wait
docker pull staphb/fastqc
wait
docker pull ewels/multiqc
wait
docker pull lethalfang/somaticseq
wait
docker pull dancooke/octopus
wait
docker pull etal/cnvkit
wait
docker pull 31071993/cfdna_pipeline_v2:pipeline_v2_oncoprint
