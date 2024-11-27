#!/bin/sh
umask 0022
cp /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem /opt/app-root/src/ca-trust/
if [ -d /opt/custom-certificates ]; then
  echo "Trusting custom certificates from /opt/custom-certificates."
  for cert_file in /opt/custom-certificates/*; do
    if [ -f "${cert_file}" ] && grep -q "BEGIN CERTIFICATE" "${cert_file}"; then
      cat "${cert_file}" >> /opt/app-root/src/ca-trust/tls-ca-bundle.pem
    fi
  done
fi
export NODE_EXTRA_CA_CERTS=/opt/app-root/src/ca-trust/tls-ca-bundle.pem

if [ "$#" -gt 0 ]; then
  # Got started with arguments
  exec n8n "$@"
else
  # Got started without arguments
  exec n8n
fi
