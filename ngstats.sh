#!/bin/bash

LOG_DIR="/var/log/nginx"
VISITORS=0
CARRY=0
CARRY_DATE=""
echo "date, visitor_count"

bots=("Googlebot" "DuckDuckGo-Favicons-Bot" "MJ12bot" "Applebot" "bingbot" "AhrefsBot" "GeedoBot" "PetalBot" "AdsBot-Google" "CensysInspect" "Expanse" "google-xrawler" "AdBot" "webmeup-crawler.com" "crawler_eb_germany_2.0" "SenutoBot" "DotBot" "SiteAuditBot")

# Initialize the result string
EXCLUDE=""

# Iterate over the array and append each bot with "-e" to the result string
for bot in "${bots[@]}"
do
    EXCLUDE+=" -e $bot"
done


for LOG_FILE in $(ls -vr "$LOG_DIR"/access.log*); do

    if [[ "$LOG_FILE" == *.gz ]]; then
        CMD="zcat $LOG_FILE"
    else
        CMD="cat $LOG_FILE"
    fi

    DATES=($(eval "$CMD" | awk '{print $4}' | cut -c 2-12 | sort -u))

    for i in "${!DATES[@]}"; do
            DATE="${DATES[$i]}"
            VISITORS_THIS_DAY=$(eval "$CMD" | grep $DATE | grep -E 'GET (/termek/.*|/) HTTP/[21]\.[01]" 2.*' | grep -v $EXCLUDE -e $1 | wc -l)
            VISITORS=$((VISITORS + VISITORS_THIS_DAY))
            if [ $i -eq 0 ] || [ $i -ne $((${#DATES[@]} - 1)) ]; then
                    if [[ $CARRY == 0 ]]; then
                            echo "$DATE, $VISITORS_THIS_DAY"
                    elif [[ $DATE == $CARRY_DATE ]]; then
                            TOTAL_VISITORS=$(($VISITORS_THIS_DAY+$CARRY))
                            echo "$DATE, $TOTAL_VISITORS"
                    else
                            echo "$CARRY_DATE: $CARRY"
                            echo "$DATE, $VISITORS_THIS_DAY"
                    fi
                    CARRY=0
                    CARRY_DATE=""
            else
                    CARRY=$VISITORS_THIS_DAY
                    CARRY_DATE=$DATE
            fi
    done
done
