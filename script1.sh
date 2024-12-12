#!/bin/bash

# Definir variaveis para criação das diretorias
base_dir="$PWD"

data_dir="$base_dir/raw_data"
fastqc1_dir="$base_dir/fastqc1"
fastqc2_dir="$base_dir/fastqc2"
fastp_dir="$base_dir/fastp"
multiqc1_dir="$base_dir/multiqc1"
multiqc2_dir="$base_dir/multiqc2"

output_dirs=(
    "$fastqc1_dir"
    "$fastqc2_dir"
    "$fastp_dir"
    "$multiqc1_dir"
    "$multiqc2_dir"
)

# Criar as subdiretorias
for sub_dir in "${output_dirs[@]}"; do
    if [ -d "$sub_dir" ]; then
        echo "Directory $sub_dir already exists!!!!"
    else
        mkdir -p "$sub_dir"
        echo ">[Created directory $sub_dir]<"
    fi
done

