#!/bin/bash

LOG_DIR="/var/log/nginx"
bots=()
polite_bots=()

function get_bots {
        ibots=$(eval "$1" |
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
            sed -r 's/[;()\+]//g' |
            sed -r 's/[ \t]*$//' |
            sed -r 's/^[ \t]*//' |
            sed -r 's/[ \t]+/ /' |
            sort -u |
            sed 's/ /===/g')
}

for LOG_FILE in $(ls -vr "$LOG_DIR"/access.log*); do
    if [[ "$LOG_FILE" == *.gz ]]; then
        CMD="zcat $LOG_FILE"
    else
        CMD="cat $LOG_FILE"
    fi
    echo "reading $LOG_FILE"
    get_bots "$CMD"
    bots=("${bots[@]}" $ibots)
    get_bots "$CMD | grep robots.txt"
    polite_bots=("${polite_bots[@]}" $ibots)
done

for bot in "${bots[@]}"; do
        echo $bot;
done | sed 's/===/ /g' | sort -u > bots_all.txt

for bot in "${polite_bots[@]}"; do
        echo $bot;
done | sed 's/===/ /g' | sort -u > bots_polite.txt

comm -23 bots_all.txt bots_polite.txt --check-order > bots_impolite.txt

echo ""
echo ""
echo "Polite Bots (reading robots.txt):"
echo "================================="
echo ""
cat bots_polite.txt
echo ""
echo ""
echo "Impolite Bots (not reading robots.txt):"
echo "======================================="
echo ""
cat bots_impolite.txt
