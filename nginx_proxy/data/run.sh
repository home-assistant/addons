#!/usr/bin/env bashio
set -e

DHPARAMS_PATH=/data/dhparams.pem

SNAKEOIL_CERT=/data/ssl-cert-snakeoil.pem
SNAKEOIL_KEY=/data/ssl-cert-snakeoil.key

CLIENT_CERT_CA_CERT=/data/ca-root.pem
CLIENT_CERT_CA_KEY=/data/ca-key.pem
CLIENT_CERT_SERVER_KEY=/data/server_private.key_encrypted
CLIENT_CERT_SERVER_KEY_PWLESS=/data/server_passwordless_private.key
CLIENT_CERT_SERVER_CSR=/data/server_request.csr
CLIENT_CERT_SERVER_CERT=/data/server_certificate.crt
CLIENT_CERT_CLIENT_KEY=/data/end_user_private.key_encrypted
CLIENT_CERT_CLIENT_CSR=/data/end_user_certificate_request.csr
CLIENT_CERT_CLIENT_CERT=/data/end_user_certificate.crt
CLIENT_CERT_CLIENT_EXPORT=/data/end_user_certificate_and_private_key.pfx


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
CLIENT_COMMON_NAME=$(bashio::config 'client_cert.client_common_name')

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
    if bashio::fs.file_exists "${CLIENT_CERT_CLIENT_EXPORT}"; then
            bashio::log.info "Certificates already created, skipping"
    else
        bashio::log.info "Creating Certificate Authority private Key"
        openssl genrsa -aes256 -passout pass:"$CA_PASS" -out "${CLIENT_CERT_CA_KEY}" 2048
        bashio::log.info "Creating Certificate Authority certificate"
        openssl req -x509 -new -nodes \
            -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORGANIZATION}/CN=${COMMON_NAME}" \
            -passin pass:"${CA_PASS}" \
            -extensions v3_ca -key "${CLIENT_CERT_CA_KEY}" -days 1024 \
            -out "${CLIENT_CERT_CA_CERT}" -sha512
        
        bashio::log.info "Generating server certificate"
        openssl genrsa -des3 -passout pass:"${SERVER_PASS}" -out "${CLIENT_CERT_SERVER_KEY}" 4096
        openssl rsa -in "${CLIENT_CERT_SERVER_KEY}" -passin pass:"${SERVER_PASS}" -out "${CLIENT_CERT_SERVER_KEY_PWLESS}"
        bashio::log.info "Generating server certificate signing request"
        openssl req -new -key "${CLIENT_CERT_SERVER_KEY_PWLESS}" \
            -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORGANIZATION}/CN=${COMMON_NAME}" \
            -out "${CLIENT_CERT_SERVER_CSR}"
        bashio::log.info "Signing server certificate signing request"
        openssl x509 -req -days 1000 \
            -passin pass:"${CA_PASS}" \
            -in "${CLIENT_CERT_SERVER_CSR}" \
            -CA "${CLIENT_CERT_CA_CERT}" -CAkey "${CLIENT_CERT_CA_KEY}" -set_serial 00001 \
            -out "${CLIENT_CERT_SERVER_CERT}"
        
        bashio::log.info "Generating user certificate"
        openssl genrsa -des3 -passout pass:"${USER_PASS}" -out "${CLIENT_CERT_CLIENT_KEY}" 4096
        bashio::log.info "Generating user certificate signing request"
        openssl req -new -passin pass:"${USER_PASS}" -key "${CLIENT_CERT_CLIENT_KEY}" \
            -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORGANIZATION}/CN=${CLIENT_COMMON_NAME}" \
            -out "${CLIENT_CERT_CLIENT_CSR}"
        bashio::log.info "Signing user certificate signing request"
        openssl x509 -req -days 1000 \
            -passin pass:"${CA_PASS}" \
            -in "${CLIENT_CERT_CLIENT_CSR}" \
            -CA "${CLIENT_CERT_CA_CERT}" -CAkey "${CLIENT_CERT_CA_KEY}" -set_serial 00001 \
            -out "${CLIENT_CERT_CLIENT_CERT}"
        bashio::log.info "Exporting user certificate and private key as PKCS#12 package"
        openssl pkcs12 -export -passin pass:"${USER_PASS}" -out "${CLIENT_CERT_CLIENT_EXPORT}" -inkey "${CLIENT_CERT_CLIENT_KEY}" -passout pass:"${USER_EXPORT_PASS}" -in "${CLIENT_CERT_CLIENT_CERT}"

        bashio::log.info "Enable Client Certificate validation in nginx.conf"
        sed -i "s/ssl_verify_client off/ssl_verify_client on/g" /etc/nginx.conf

        bashio::log.info "Copying certificates to ssl folder"
        cp -f "${CLIENT_CERT_CA_CERT}" "/ssl/ca-root.pem" 
        cp -f "${CLIENT_CERT_CLIENT_EXPORT}" "/ssl/end_user_certificate_and_private_key.pfx"      

        bashio::log.info "Copying root certificate to nginx folder"
        cp -f "${CLIENT_CERT_CA_CERT}" "/etc/nginx/ca-root.pem"
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
