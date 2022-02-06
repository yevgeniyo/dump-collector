#!/usr/bin/env bash

while true; do
    for FILE in /dumps/*; do
        if [ -d $FILE ]; then
            # directory: move as is
            DIR=$(basename $FILE)
            aws s3 mv $FILE s3://$S3bucket/$DIR --recursive
            RESULT=$?
            if [ $RESULT -ne 0 ]; then
                echo "Failed to send dump dir $FILE to S3 bucket $S3bucket"
            fi
        elif [ -f $FILE ]; then
            # file: move to a directory named with the file timestamp
            TIMESTAMP=$(date -r $FILE +"%Y_%m_%d_%H_%M_%S")
            aws s3 mv $FILE s3://$S3bucket/$TIMESTAMP/$FILE
            RESULT=$?
            if [ $RESULT -ne 0 ]; then
                echo "Failed to send dump file $FILE to S3 bucket $S3bucket"
            fi
        fi
    done
    sleep 60s
done
