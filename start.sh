#!/bin/bash

service ssh start
service tor start
sleep 5
if [ -f /var/lib/tor/hidden_service/hostname ]; then
    echo "Tor Hidden Service address:"
    cat /var/lib/tor/hidden_service/hostname
fi
nginx -g "daemon off;"