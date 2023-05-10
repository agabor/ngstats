#!/bin/bash

LOG_DIR="/var/log/nginx"
VISITORS=0
CARRY=0
CARRY_DATE=""
echo "date, visitor_count"

for LOG_FILE in $(ls -vr "$LOG_DIR"/access.log*); do

    if [[ "$LOG_FILE" == *.gz ]]; then
        CMD="zcat $LOG_FILE"
    else
        CMD="cat $LOG_FILE"
    fi

    DATES=($(eval "$CMD" | awk '{print $4}' | cut -c 2-12 | sort -u))

    for i in "${!DATES[@]}"; do
            DATE="${DATES[$i]}"
            VISITORS_THIS_DAY=$(eval "$CMD" | grep $DATE | grep -E 'GET (/termek/.*|/) HTTP/[21]\.[01]" 2.*' | grep -i -v -e bot -e crawler -e xrawler -e $1 | wc -l)
            echo "$DATE, $VISITORS_THIS_DAY"
    done
done
