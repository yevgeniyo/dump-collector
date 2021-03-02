#!/usr/bin/env bash

while true; do

    now=$(date +%Y%m%d%H%M%S)
    rclone move /dumps remote:$S3bucket/$(date +%Y_%m_%d_%H_%M_%S)
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echo "Failed to send dump files to S3 bucket ${S3bucket}"
    fi

    sleep 60s
done

