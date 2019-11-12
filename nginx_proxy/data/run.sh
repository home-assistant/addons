#!/usr/bin/env bashio
set -e

DHPARAMS_PATH=/data/dhparams.pem

SNAKEOIL_CERT=/data/ssl-cert-snakeoil.pem
SNAKEOIL_KEY=/data/ssl-cert-snakeoil.key

CLOUDFLARE_CONF=/data/cloudflare.conf

DOMAIN=$(bashio::config 'domain')
KEYFILE=$(bashio::config 'keyfile')
CERTFILE=$(bashio::config 'certfile')
HSTS=$(bashio::config 'hsts')

CA_PASS=$(bashio::config "client_cert.ca_password")
SERVER_PASS="$(bashio::config 'client_cert.server_password')"
USER_PASS="$(bashio::config 'client_cert.user_password')"
USER_EXPORT_PASS="$(bashio::config 'client_cert.user_export_password')"

COUNTRY=$(bashio::config 'client_cert.country')
STATE=$(bashio::config 'client_cert.state')
CITY=$(bashio::config 'client_cert.city')
ORGANIZATION=$(bashio::config 'client_cert.organization')
COMMON_NAME=$(bashio::config 'client_cert.common_name')

# Generate dhparams
if ! bashio::fs.file_exists "${DHPARAMS_PATH}"; then
    bashio::log.info  "Generating dhparams (this will take some time)..."
    openssl dhparam -dsaparam -out "$DHPARAMS_PATH" 4096 > /dev/null
fi

if ! bashio::fs.file_exists "${SNAKEOIL_CERT}"; then
    bashio::log.info "Creating 'snakeoil' self-signed certificate..."
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout $SNAKEOIL_KEY -out $SNAKEOIL_CERT -subj '/CN=localhost'
fi

if bashio::config.true 'cloudflare'; then
    sed -i "s|#include /data/cloudflare.conf;|include /data/cloudflare.conf;|" /etc/nginx.conf
    # Generate cloudflare.conf
    if ! bashio::fs.file_exists "${CLOUDFLARE_CONF}"; then
        bashio::log.info "Creating 'cloudflare.conf' for real visitor IP address..."
        echo "# Cloudflare IP addresses" > $CLOUDFLARE_CONF;
        echo "" >> $CLOUDFLARE_CONF;

        echo "# - IPv4" >> $CLOUDFLARE_CONF;
        for i in $(curl https://www.cloudflare.com/ips-v4); do
            echo "set_real_ip_from ${i};" >> $CLOUDFLARE_CONF;
        done

        echo "" >> $CLOUDFLARE_CONF;
        echo "# - IPv6" >> $CLOUDFLARE_CONF;
        for i in $(curl https://www.cloudflare.com/ips-v6); do
            echo "set_real_ip_from ${i};" >> $CLOUDFLARE_CONF;
        done

        echo "" >> $CLOUDFLARE_CONF;
        echo "real_ip_header CF-Connecting-IP;" >> $CLOUDFLARE_CONF;
    fi
fi

#Create necessary openssl CA and certs for client certificate authentication
if bashio::config.true 'client_cert.active'; then
    if bashio::fs.file_exists "end_user_certificate_and_private_key.pfx"; then
            bashio::log.info "Certificates already created, skipping"
    else
        bashio::log.info "Creating Certificate Authority"
        openssl genrsa -aes256 -passout pass:"$CA_PASS" -out ca-key.pem 2048
        bashio::log.info "Creating root certificate"
        openssl req -x509 -new -nodes \
            -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORGANIZATION}/CN=${COMMON_NAME}" \
            -passin pass:"${CA_PASS}" \
            -extensions v3_ca -key ca-key.pem -days 1024 \
            -out ca-root.pem -sha512
        
        bashio::log.info "Generating server certificate"
        openssl genrsa -des3 -passout pass:"${SERVER_PASS}" -out server_private.key_encrypted 4096
        openssl rsa -in server_private.key_encrypted -passin pass:"${SERVER_PASS}" -out server_passwordless_private.key
        bashio::log.info "Generating server signing request"
        openssl req -new -key server_passwordless_private.key \
            -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORGANIZATION}/CN=${COMMON_NAME}" \
            -out server_request.csr
        bashio::log.info "Signing server signing request"
        openssl x509 -req -days 1000 \
            -passin pass:"${CA_PASS}" \
            -in server_request.csr \
            -CA ca-root.pem -CAkey ca-key.pem -set_serial 00001 \
            -out server_certificate.crt
        
        bashio::log.info "Generating user certificate"
        openssl genrsa -des3 -passout pass:"${USER_PASS}" -out end_user_private.key_encrypted 4096
        bashio::log.info "Generating user signing request"
        openssl req -new -passin pass:"${USER_PASS}" -key end_user_private.key_encrypted \
            -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORGANIZATION}/CN=${COMMON_NAME}" \
            -out end_user_certificate_request.csr
        bashio::log.info "Signing user signing request"
        openssl x509 -req -days 1000 \
            -passin pass:"${CA_PASS}" \
            -in end_user_certificate_request.csr \
            -CA ca-root.pem -CAkey ca-key.pem -set_serial 00001 \
            -out end_user_certificate.crt
        bashio::log.info "Export user certificate as PKCS#12 package"
        openssl pkcs12 -export -passin pass:"${USER_PASS}" -out end_user_certificate_and_private_key.pfx -inkey end_user_private.key_encrypted -passout pass:"${USER_EXPORT_PASS}" -in end_user_certificate.crt

        bashio::log.info "Enable Client Certificate validation in nginx.conf"
        sed -i "s/ssl_verify_client off/ssl_verify_client on/g" /etc/nginx.conf

        bashio::log.info "Creating client_cert folder within ssl folder"
        mkdir -p "/ssl/client_cert/"
        bashio::log.info "Copying certificates to ssl folder"
        cp -f ca-root.pem "/ssl/client_cert/ca-root.pem"
        cp -f server_certificate.crt "/ssl/client_cert/server_certificate.crt"
        cp -f end_user_certificate.crt "/ssl/client_cert/end_user_certificate.crt"        
        cp -f end_user_certificate_and_private_key.pfx "/ssl/client_cert/end_user_certificate_and_private_key.pfx"

        bashio::log.info "Copying root certificate to nginx folder"
        cp -f ca-root.pem "/etc/nginx/ca-root.pem"
    fi
fi


# Prepare config file
sed -i "s/%%FULLCHAIN%%/$CERTFILE/g" /etc/nginx.conf
sed -i "s/%%PRIVKEY%%/$KEYFILE/g" /etc/nginx.conf
sed -i "s/%%DOMAIN%%/$DOMAIN/g" /etc/nginx.conf

[ -n "$HSTS" ] && HSTS="add_header Strict-Transport-Security \"$HSTS\";"
sed -i "s/%%HSTS%%/$HSTS/g" /etc/nginx.conf

# Allow customize configs from share
if bashio::config.true 'customize.active'; then
    CUSTOMIZE_DEFAULT=$(bashio::config 'customize.default')
    sed -i "s|#include /share/nginx_proxy_default.*|include /share/$CUSTOMIZE_DEFAULT;|" /etc/nginx.conf
    CUSTOMIZE_SERVERS=$(bashio::config 'customize.servers')
    sed -i "s|#include /share/nginx_proxy/.*|include /share/$CUSTOMIZE_SERVERS;|" /etc/nginx.conf
fi

# start server
bashio::log.info "Running nginx..."
exec nginx -c /etc/nginx.conf < /dev/null
