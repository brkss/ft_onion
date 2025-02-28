FROM ubuntu:20.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y nginx openssh-server tor && \
    rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY index.html /usr/share/nginx/html/index.html
COPY nginx.conf /etc/nginx/nginx.conf
COPY sshd_config /etc/ssh/sshd_config
COPY torrc /etc/tor/torrc

# Prepare directories for Tor hidden service with correct permissions
RUN mkdir -p /var/lib/tor/hidden_service && \
    chown -R debian-tor:debian-tor /var/lib/tor && \
    chmod 700 /var/lib/tor && \
    chmod 700 /var/lib/tor/hidden_service

# Expose ports if necessary (internal exposure only, not mapping host ports)
EXPOSE 80 4242

# Start all services using a supervisor or a simple script
CMD tor --verify-config && \
    service tor start && \
    sleep 3 && \
    if [ -f /var/lib/tor/hidden_service/hostname ]; then \
        echo "Tor Hidden Service address:" && \
        cat /var/lib/tor/hidden_service/hostname; \
    fi && \
    service ssh start && \
    nginx -g 'daemon off;'