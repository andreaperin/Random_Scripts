#!/bin/bash

function help() {
    echo "TO UPLOAD:"
    echo " - ./sharelink.sh /path/to/file --password password --max-downloads 1"
    echo " - ./sharelink.sh /path/to/file --max-downloads 1"
    echo 
    echo "TO DELETE:"
    echo " - ./sharelink.sh --delete https://delete/url"
    echo " - ./sharelink.sh --delete https://delete/url"
    echo 
    echo "TO DOWNLOAD:"
    echo " - ./sharelink.sh --password password --download https://download/url -o /path/to/output/folder"
    echo " - ./sharelink.sh --password password --download https://download/url"
    echo " - ./sharelink.sh --download https://download/url"
    
}

########################################################
########################################################
########################################################
delete='false'
download='false'
max_downloads='10'
password='null'
output='.'

POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --delete)
        delete='true'
        shift # past argument
        ;;
        --download)
        download='true'
        shift # past argument
        ;;
        -m|--max-downloads)
        max_downloads="$2"
        shift # past argument
        shift # past value
        ;;
        -p|--password)
        password="$2"
        shift # past argument
        shift # past value
        ;;
        -o|--output)
        output="$2"
        shift # past argument
        shift # past value
        ;;
        -h|--help)
        help
        exit
        ;;
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

########################################################
########################################################
########################################################

if [ "$delete" == 'true' ]; then

    for url in $@; do
        curl -X DELETE $url
    done

elif [ "$download" = 'true' ]; then

    for url in $@; do
        filename="${url##*/}"
        echo "filename $filename"
        if [ "$password" = 'null' ]; then
            curl "$url" > $output/$filename
        else
            curl "$url" | gpg -d --batch --passphrase "$password" -o $output/$filename
        fi
    done

else
    if [ ! -n "$1" ]; then
        folder=$PWD
    else 
        folder=$1
    fi

    shift 
    args=$@

    FILES=$(find $folder -type f -name '*')

    for file in $FILES;
    do
        echo "-----------------------------------------------"
        echo "Input: $file"
        filename_with_extension=$(basename "$file"); # without path
        filename="${filename_with_extension%.*}" # without extension
        dirname=$(dirname "$file"); # folder name
        
        if [ "$password" = 'null' ]; then
            if [ "$max_downloads" = 'null' ]; then
                result=$(curl -sD - --upload-file ${file} https://transfer.sh/${filename_with_extension})
            else
                result=$(curl -sD - --upload-file ${file} https://transfer.sh/${filename_with_extension} -H "Max-Downloads: $max_downloads")
            fi
        else
            result=$(cat ${file} | gpg -c --batch --passphrase "$password" | curl -sD - -X PUT --upload-file "-" https://transfer.sh/${filename_with_extension} -H "Max-Downloads: $max_downloads")
        fi

        echo "$result"

        delete_url=$(echo "$result" | grep 'x-url-delete:')
        url=$(echo "$result" | tail -n 1)

        echo "-----------------------------------------------"
        echo "File: ${file}"
        echo "Link: ${url}"
        echo "DeleteLink: ${delete_url}"
        echo "-----------------------------------------------"
    done

fi

