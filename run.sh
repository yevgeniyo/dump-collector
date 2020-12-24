#!/usr/bin/env bash

while true; do

    now=$(date +%Y%m%d%H%M%S)
    rclone move /dumps remote:$S3bucket/$(date +%Y_%m_%d_%H_%M_%S)
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echo "Failed to send dump files to S3 bucket ${S3bucket}"
    fi

#    echo "Checking /dumps size on the host"
#    dumps_size=`du -s /dumps | awk '{print $1}'`
#    if [ "$dumps_size" -ge 10000000 ]; then
#        echo "Dumps size more than 10G, cleaning /dumps"
#        rm -rf /dumps/*
#    else echo "/dumps size is $dumps_size bytes and less than 10000000 (10G), nothing to do"
#    fi

    sleep 60s
done