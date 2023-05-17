#!/bin/bash

LOG_DIR="/var/log/nginx"

if [[ $# -ne 2 ]]; then
        echo "usage: visitors.sh [product_prefix] [domain]"
        echo "where:"
        echo "  [product_prefix] is the prefix of your product page"
        echo "  [domain] is the domain name of your page without http:// or https://"
        echo "example: visitors.sh /product/ example.com"
        exit 0
fi

echo "date; visitor_count"

for LOG_FILE in $(ls -vr "$LOG_DIR"/access.log*); do

    if [[ "$LOG_FILE" == *.gz ]]; then
        CMD="zcat $LOG_FILE"
    else
        CMD="cat $LOG_FILE"
    fi

    DATES=($(eval "$CMD" | awk '{print $4}' | cut -c 2-12 | sort -u))
    DATE="${DATES[0]}"
    VISITORS=$(eval "$CMD" | grep $DATE | grep -E "GET ($1.*|/) HTTP/[21]\.[01]\" 2.*" | grep  -v -i -E "(bot|crawler|xrawler|scan|$2)" | wc -l)
    echo "$DATE; $VISITORS"
done
