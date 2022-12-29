#!/bin/bash

#Input arguments
home_dir=$1

#Script

#Docker Image: AGeNT
cd $home_dir/CSF_CFDNA_SEQ/docker_images/agent
docker build -t 31071993/csf_cfdna_seq:agent .
wait
echo "AGeNT Docker Image build"

#Docker Image: bcl-convert
cd $home_dir/CSF_CFDNA_SEQ/docker_images/bcl_convert
docker build -t 31071993/csf_cfdna_seq:bcl_convert .
wait
echo "bcl-convert Docker Image build"

#Docker Image: bwa_mem2
cd $home_dir/CSF_CFDNA_SEQ/docker_images/bwa_mem2
docker build -t 31071993/csf_cfdna_seq:bwa_mem2 .
wait
echo "bwa_mem2 Docker Image build"

#Docker Image: Excel Report
cd $home_dir/CSF_CFDNA_SEQ/docker_images/create_report
docker build -t 31071993/csf_cfdna_seq:snv_indel_report .
wait
echo "Excel report Docker Image build"

#Docker Image: Special Positions
cd $home_dir/CSF_CFDNA_SEQ/docker_images/special_positions
docker build -t 31071993/csf_cfdna_seq:special_positions .
wait
echo "Special Positions Docker Image build"

#Docker Image: MYD88:p.L265P
cd $home_dir/CSF_CFDNA_SEQ/MYD88/docker_images
docker build -t 31071993/myd88_l265p .
wait
echo "MYD88:p.L265P Docker Image build"