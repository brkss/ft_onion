FROM ubuntu:20.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y nginx openssh-server tor && \
    rm -rf /var/lib/apt/lists/*

    
COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/nginx.conf
COPY sshd_config /etc/ssh/sshd_config
COPY torrc /etc/tor/torrc


RUN mkdir -p /var/lib/tor/hidden_service && \
    chown -R debian-tor:debian-tor /var/lib/tor && \
    chmod 700 /var/lib/tor && \
    chmod 700 /var/lib/tor/hidden_service

RUN useradd -m -s /bin/bash sshuser && \
    echo "sshuser:pass@" | chpasswd


EXPOSE 80 4242

RUN echo '#!/bin/bash\n\
service ssh start\n\
service tor start\n\
sleep 5\n\
if [ -f /var/lib/tor/hidden_service/hostname ]; then\n\
    echo "Tor Hidden Service address:"\n\
    cat /var/lib/tor/hidden_service/hostname\n\
fi\n\
nginx -g "daemon off;"\n\
' > /start.sh && chmod +x /start.sh


CMD ["/start.sh"]