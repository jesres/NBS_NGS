#!/bin/bash

project_name=$1
main_storage_dir=$2

if [ $# -ne 2 ];then
    printf "Usage: $0 project_name main_storage_dir" 
    exit 1
fi


if [ ! -d $main_storage_dir ]; then
  echo $main_storage_dir "doesn't exists. I'm going to create it now, but double check this is where you want to store your project";
fi

mkdir -p $main_storage_dir;

if [ ! -d $main_storage_dir/$project_name ]; then
  mkdir -p $main_storage_dir/$project_name;
else
  echo $main_storage_dir"/"$project_name "already exists. Please choose another name";
fi

if [ ! -d $main_storage_dir/$project_name/logs ]; then
  mkdir -p $main_storage_dir/$project_name/logs;
else
  echo $main_storage_dir"/"$project_name"/logs already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/raw ]; then
  mkdir -p $main_storage_dir/$project_name/raw;
else
  echo $main_storage_dir"/"$project_name"/raw already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/work ]; then
  mkdir -p $main_storage_dir/$project_name/work;
else
  echo $main_storage_dir"/"$project_name"/work already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/work/qc ]; then
  mkdir -p $main_storage_dir/$project_name/work/qc;
else
  echo $main_storage_dir"/"$project_name"/work/qc already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/work/qc/fastqc ]; then
  mkdir -p $main_storage_dir/$project_name/work/qc/fastqc;
else
  echo $main_storage_dir"/"$project_name"/work/qc/fastqc already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/work/qc/bcftools-stats ]; then
  mkdir -p $main_storage_dir/$project_name/work/qc/bcftools-stats;
else
  echo $main_storage_dir"/"$project_name"/work/qc/bcftools-stats already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/work/qc/verifyBamID ]; then
  mkdir -p $main_storage_dir/$project_name/work/qc/verifyBamID;
else
  echo $main_storage_dir"/"$project_name"/work/qc/verifyBamID already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/work/qc/TargetedPcrMetrics ]; then
  mkdir -p $main_storage_dir/$project_name/work/qc/TargetedPcrMetrics;
else
  echo $main_storage_dir"/"$project_name"/work/qc/TargetedPcrMetrics already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/work/qc/QualiMap ]; then
  mkdir -p $main_storage_dir/$project_name/work/qc/QualiMap;
else
  echo $main_storage_dir"/"$project_name"/work/qc/QualiMap already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/work/reference ]; then
  mkdir -p $main_storage_dir/$project_name/work/reference;
else
  echo $main_storage_dir"/"$project_name"/work/reference already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/work/DECoN ]; then
  mkdir -p $main_storage_dir/$project_name/work/DECoN;
else
  echo $main_storage_dir"/"$project_name"/work/DECoN already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/final ]; then
  mkdir -p $main_storage_dir/$project_name/final;
else
  echo $main_storage_dir"/"$project_name"/final already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/final/qc ]; then
  mkdir -p $main_storage_dir/$project_name/final/qc;
else
  echo $main_storage_dir"/"$project_name"/final/qc already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/final/vcfs ]; then
  mkdir -p $main_storage_dir/$project_name/final/vcfs;
else
  echo $main_storage_dir"/"$project_name"/final/vcfs already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/final/qc/coverage ]; then
  mkdir -p $main_storage_dir/$project_name/final/qc/coverage;
else
  echo $main_storage_dir"/"$project_name"/final/qc/coverage already exists. This shouldn't happen for a new project";
fi

if [ ! -d $main_storage_dir/$project_name/final/DECoN ]; then
  mkdir -p $main_storage_dir/$project_name/final/DECoN;
else
  echo $main_storage_dir"/"$project_name"/final/DECoN already exists. This shouldn't happen for a new project";
fi