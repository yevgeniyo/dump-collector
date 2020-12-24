#!/usr/bin/env bash

while true; do
    echo "syncing /dumps to $S3bucket"
    #TODO delete old files, add timestamps
    rclone move /dumps remote:$S3bucket

#    echo "Checking /dumps size on the host"
#    dumps_size=`du -s /dumps | awk '{print $1}'`
#    if [ "$dumps_size" -ge 10000000 ]; then
#        echo "Dumps size more than 10G, cleaning /dumps"
#        rm -rf /dumps/*
#    else echo "/dumps size is $dumps_size bytes and less than 10000000 (10G), nothing to do"
#    fi

    sleep 60s
done