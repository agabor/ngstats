#!/usr/bin/env bash

HUMANS=$(grep -E 'GET (/termek/.*|/) HTTP/[21]\.[01]" 2.*' /var/log/nginx/access.log |  grep -v -i -E "(bot|crawler|xrawler|scan)" | wc -l)
BOTS=$(grep -E 'GET (/termek/.*|/) HTTP/[21]\.[01]" 2.*' /var/log/nginx/access.log |  grep -i -E "(bot|crawler|xrawler|scan)" | wc -l)

echo "Your website has been visitied by $HUMAN humans and $BOTS bots today"
