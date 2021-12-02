#!/usr/bin/env bash

while true; do
    for FILE in /dumps/*; do
        if [ -d $FILE ]; then
            # directory: move as is
            rclone move $FILE remote:$S3bucket
            RESULT=$?
            if [ $RESULT -ne 0 ]; then
                echo "Failed to send dump dir $FILE to S3 bucket $S3bucket"
            fi
        else
            # file: move to a directory named with the file timestamp
            TIMESTAMP=$(stat -f "%Sm" -t "%Y-%m-%d-%H-%M-%S" $FILE)
            rclone move $FILE remote:$S3bucket/$TIMESTAMP
            RESULT=$?
            if [ $RESULT -ne 0 ]; then
                echo "Failed to send dump file $FILE to S3 bucket $S3bucket"
            fi
        fi
    done
    sleep 60s
done
