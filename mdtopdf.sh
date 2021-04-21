#!/bin/bash

# a script to convert a markdown file to a pdf

function help() {
    echo "TO CONVERT a single markdown file:"
    echo " - mdtopdf - i <input_file_name.md> -o <output_file_name.pdf>"
    echo " - mdtopdf - i <input_file_name.md>"
    echo "TO CONVERT all markdown files in a directory"
    echo " - mdtopdf - i <path_to_directory>"
    echo " this action requires confirm and output files will have the same name of input files"
}

# Default
output_file=null

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -i | --input)
        input_file="$2"
        shift # past argument
        shift # past value
        ;;
    -o | --output)
        output_file="$2"
        shift # past argument
        shift # past value
        ;;
    -h | --help)
        help
        exit
        ;;
    *)                     # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift              # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ -d "$input_file" ]; then
    echo "$input_file is a directory"

    echo "Do you want to conver all markdown files in $input_file ? Press y to continue or any other input to exit"
    while :; do
        read -n 1 k <&1
        if [[ $k = y ]]; then
            printf "\n"
            echo "Converting all markdown-file in $input_file"
            echo "..."
            # inserire un wait till enter is push
            for i in $(find ./$input_file -name "*.md" -type f); do
                echo "Starting conversion of Document $i"
                input_file=$i
                if [ "$output_file" = 'null' ]; then
                    output_file=${input_file%.*}.pdf
                    pandoc $input_file --pdf-engine=xelatex -o $output_file -V geometry:margin=1in
                    echo "Document $output_file have been created!"
                    output_file='null'
                else
                    echo "you should no pass any output file name when converting all files in a directory"
                    exit
                fi
            done
        else
            exit
        fi
    done
####
elif [ -f "$input_file" ]; then
    echo "$input_file is a file"
    if [ "$output_file" = 'null' ]; then
        output_file=${input_file%%.*}.pdf
    fi
    if [ -z "$input_file" ]; then
        echo "inserisci un file di input"
        exit
    fi
    pandoc $input_file --pdf-engine=xelatex -o $output_file -V geometry:margin=1in

####
else
    echo "$input_file is not valid"
    exit
fi

# if [ "$output_file" = 'null' ]; then
#     output_file=${input_file%%.*}.pdf
# fi
# if [ -z "$input_file" ]; then
#     echo "inserisci l'input"
#     exit
# fi

# pandoc $input_file --pdf-engine=xelatex -o $output_file -V geometry:margin=1in
