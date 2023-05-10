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
            VISITORS_THIS_DAY=$(eval "$CMD" | awk -v date="$DATE" '!/Googlebot|Applebot|bingbot|AhrefsBot/ && $4 ~ date {print $1}' | sort -u | wc -l)
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
