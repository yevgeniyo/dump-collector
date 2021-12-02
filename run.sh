#!/usr/bin/env bash

while true; do
    for FILE in /dumps/*; do
        if [ -d $FILE ]; then
            # directory: move as is
            DIR=$(basename $FILE)
            rclone move $FILE remote:$S3bucket/$DIR
            RESULT=$?
            if [ $RESULT -ne 0 ]; then
                echo "Failed to send dump dir $FILE to S3 bucket $S3bucket"
            fi
        else
            # file: move to a directory named with the file timestamp
            TIMESTAMP=$(date -r $FILE +"%Y_%m_%d_%H_%M_%S")
            rclone move $FILE remote:$S3bucket/$TIMESTAMP
            RESULT=$?
            if [ $RESULT -ne 0 ]; then
                echo "Failed to send dump file $FILE to S3 bucket $S3bucket"
            fi
        fi
    done
    sleep 60s
done
