#!/bin/bash
  
LOG_DIR="/var/log/nginx"

bots=()

for LOG_FILE in $(ls -vr "$LOG_DIR"/access.log*); do

    if [[ "$LOG_FILE" == *.gz ]]; then
        CMD="zcat $LOG_FILE"
    else
        CMD="cat $LOG_FILE"
    fi
    #echo $LOG_FILE
    bots=("${bots[@]}" $(eval "$CMD" |
            awk -F'"' '/GET/ {print $6}' |
            grep -E -i '(bot|crawler|xcrawler|scan)' |
            awk -F 'compatible;' '{print $NF}' |
            sed -r 's/Safari\/([0-9]+\.){1,2}[0-9]+//g' |
            sed -r 's/Windows NT [0-9]+\.[0-9]+//g' |
            sed -r 's/AppleWebKit\/([0-9]+\.){2}[0-9]+ \(KHTML, like Gecko\) Version\/([0-9]+\.){2}[0-9]+//g' |
            sed 's/Macintosh//g' |
            sed 's/Mozilla\/5\.0//g' |
            sed 's/Intel//g' |
            sed 's/x64//g' |
            sed 's/x86_64//g' |
            sed 's/Win64//g' |
            sed 's/X11//g' |
            sed 's/Linux//g' |
            sed -r 's/Mac OS X ([0-9]+_){2}[0-9]+//g' |
            sed -r 's/Chrome\/([0-9]+\.){3}[0-9]+//g' |
            sed 's/http/ http/g' |
            sed 's/[;()\+]//g' |
            sed 's/[ \t]*$//' |
            sed 's/^[ \t]*//' |
            sed 's/[ \t]+/ /' |
            sort -u |
            sed 's/ /===/g'))
done

for bot in "${bots[@]}"; do echo $bot; done | sort -u | sed 's/===/ /g'
