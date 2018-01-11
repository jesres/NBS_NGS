#!/bin/bash
#set -x

input=$1
output=$2


if [ $# -ne 2 ];then
    printf "Usage: $0 input_file output_file\n" 
    exit 1
fi
