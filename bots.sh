#!/usr/bin/env bash

grep -i -E "(bot|crawler|xrawler|scan)" /var/log/nginx/access.log | grep compatible | awk -F "compatible;" '{print $NF}' | awk -F ")" '{print $1}' | sort | uniq
grep -i -E "(bot|crawler|xrawler|scan)" /var/log/nginx/access.log | grep -v compatible | grep Google | awk -F "\"" '{print $(NF-1)}' | sort | uniq
