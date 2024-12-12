#!/bin/bash

# Definir variaveis para as diretorias
base_dir="$PWD"

data_dir="$base_dir/raw_data"
fastqc1_dir="$base_dir/fastqc1"
fastqc2_dir="$base_dir/fastqc2"
fastp_dir="$base_dir/fastp"
multiqc1_dir="$base_dir/multiqc1"
multiqc2_dir="$base_dir/multiqc2"

conda_env="tools_qc"

# Activar conda
eval "$(conda shell.bash hook)"
conda activate "$conda_env"

#Função para correr o comando MultiQC
function run_fastqc() {
    result=0
    # Itera o 1o elemento de todos os pares
    for file1 in "$1/"*_1_*".fastq.gz"; do
        # Descobre o 2o elemento do par
        file2="${file1/_1_/_2_}"
        #Comando para correr o fastqc dos ficheiros
        if [[ -f "$file2" ]]; then
            fastqc "$file1" "$file2" -o "$2"

            # Guarda resultado do comando
            result=$?

            if [ $result -ne 0 ]; then
                echo "[ERROR] FastQC failed for $file1 and $file2!!"
                break
            fi
        else
            echo "[ERROR] File $file2 not found!!"
        fi
    done

    if [ $result -eq 0 ]; then
        echo -e
        echo ">>>[FastQC completed SUCCESSFULLY]<<<"
    fi

}

#Função para correr o comando MultiQC
function run_multiqc() {
    multiqc "$1" -o "$2"
    if [ $? -eq 0 ]; then
        echo -e
        echo ">>>[MultiQC completed SUCCESSFULLY]<<<"
    else
        echo "[ERROR] MultiQC failed!!"
    fi
}

#Função para correr o comando FastP
function run_fastp() {
    # Itera o 1o elemento de todos os pares
    for file1 in "$1/"*_1_*".fastq.gz"; do
        # Descobre o 2o elemento do par
        file2="${file1/_1_/_2_}"

        out1="$(basename ${file1%%.fastq.gz})_fp.fastq.gz"
        out2="$(basename ${file2%%.fastq.gz})_fp.fastq.gz"
        # Substitui _1_ por _
        report="${file1/_1_/_}" 
        report="$(basename ${report%%.fastq.gz})_fp.fastq.html"
        failed="${file1/_1_/_}"
        failed="$(basename ${failed%%.fastq.gz})_fp.fastq.txt"

        if [[ -f "$file2" ]]; then
            fastp -i $file1 -I $file2 -o "$2/$out1" -O "$2/$out2" \
            --html "$2/$report" --failed_out "$2/$failed"

            # Guarda resultado do comando
            result=$?

            if [ $result -ne 0 ]; then
                echo "[ERROR] FastP failed for $file1 and $file2!!"
            fi
        else
            echo "[ERROR] File $file2 not found!!"
        fi
    done

    if [ $result -eq 0 ]; then
        echo -e
        echo ">>>[FastP completed SUCCESSFULLY]<<<"
    fi
}

#Onde as funções vão correr os comandos 
echo -e
echo ">>>[Running FastQC (phase 1)]<<<"
echo -e
run_fastqc "$data_dir" "$fastqc1_dir"

echo -e
echo ">>>[Running MultiQC (phase 1)]<<<"
echo -e
run_multiqc "$fastqc1_dir" "$multiqc1_dir"

echo -e
echo ">>>[Running FastP]<<<"
echo -e
run_fastp "$data_dir" "$fastp_dir"

echo -e
echo ">>>[Running FastQC (phase 2)]<<<"
echo -e
run_fastqc "$fastp_dir" "$fastqc2_dir"

echo -e
echo ">>>[Running MultiQC (phase 2)]<<<"
echo -e
run_multiqc "$fastqc2_dir" "$multiqc2_dir"
