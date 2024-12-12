#!/bin/bash

# Definir variaveis para as diretorias
base_dir="$PWD"

data_dir="$base_dir/raw_data"

echo -e
echo ">>>[Counting FastQ sample reads]<<<"

# Itera o 1o elemento de todos os pares
for file1 in "$data_dir/"*_1_*".fastq.gz"; do

    sample1="$(basename ${file1%%.fastq.gz})"
    # Substitui _1_ por _
    sample="${sample1/_1_/_}"

    echo -e
    echo ">[Found sample: $sample]<"

    # Descobre o 2o elemento do par
    file2="${file1/_1_/_2_}"
    sample2="$(basename ${file2%%.fastq.gz})"

    if [[ -f "$file2" ]]; then
        file1_unzip="${file1%%.gz}"
        file2_unzip="${file2%%.gz}"

        # Gzipar os ficheiros zip para proceder à contagem de reads
        gunzip -k "$file1"
        result=$?

        if [ $result -eq 0 ]; then
            line_count1=$(wc -l < $file1_unzip)
            read_count1=$((line_count1 / 4))

            rm $file1_unzip
        else
            echo "[ERROR] Could not unzip $file1!!"
        fi

        gunzip -k "$file2"
        result=$?

        if [ $result -eq 0 ]; then
            line_count2=$(wc -l < $file2_unzip)
            read_count2=$((line_count2 / 4))

            rm $file2_unzip
        else
            echo "[ERROR] Could not unzip $file2!!"
        fi
        # Contagem dos reads
        echo "--> Initial reads in $sample1: $read_count1"
        echo "--> Initial reads in $sample2: $read_count2"
        echo "--> Total reads for $sample: $((read_count1 + read_count2))"
    else
        echo "[ERROR] Could not find 2nd sample pair: $file2!!"
    fi
done

