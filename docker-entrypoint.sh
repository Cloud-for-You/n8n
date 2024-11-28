#!/bin/sh
touch /opt/app-root/src/.n8n/.gitconfig
export GIT_CONFIG=/opt/app-root/src/.n8n/.gitconfig
cp /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem /opt/app-root/src/ca-trust/
chmod 0664 /opt/app-root/src/ca-trust/tls-ca-bundle.pem
if [ -d /opt/custom-certificates ]; then
  echo "Trusting custom certificates from /opt/custom-certificates."
  for cert_file in /opt/custom-certificates/*; do
    if [ -f "${cert_file}" ] && grep -q "BEGIN CERTIFICATE" "${cert_file}"; then
      cat "${cert_file}" >> /opt/app-root/src/ca-trust/tls-ca-bundle.pem
    fi
  done
  git config --global http.sslCAPath=/opt/app-root/src/ca-trust/ \
  git config --global http.sslCAInfo=/opt/app-root/src/ca-trust/tls-ca-bundle.pem
fi
export NODE_EXTRA_CA_CERTS=/opt/app-root/src/ca-trust/tls-ca-bundle.pem

# Configure .gitconfig


if [ "$#" -gt 0 ]; then
  # Got started with arguments
  exec n8n "$@"
else
  # Got started without arguments
  exec n8n
fi
