#!/bin/bash

case "$1" in
    'dev') INPUT='env/dev.env';;
    'prod') INPUT='env/prod.env';;
    'staging') INPUT='env/staging.env';;
    *) echo "Usage: $0 <dev|prod|staging>"
       exit 1;;

esac

# Remove CR from the end of the file
sed -i '$s/\r$//' $INPUT
while IFS='' read -r line || [[ -n "$line" ]]; do 
    DART_DEFINES="$DART_DEFINES--dart-define=$line "
done < "$INPUT"
echo "$DART_DEFINES"
