#!/bin/sh
if [ -d /opt/custom-certificates ]; then
  echo "Trusting custom certificates from /opt/custom-certificates."
  mkdir -p /opt/app-root/ca-trust
  cp /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem /opt/app-root/ca-trust/
  for cert_file in /opt/custom-certificates/*; do
    if [ -f "${cert_file}" ] && grep -q "BEGIN CERTIFICATE" "${cert_file}"; then
      cat "${cert_file}" >> /opt/app-root/ca-trust/tls-ca-bundle.pem
    fi
  done
  export NODE_EXTRA_CA_CERTS=/opt/app-root/ca-trust/tls-ca-bundle.pem
fi

if [ "$#" -gt 0 ]; then
  # Got started with arguments
  exec n8n "$@"
else
  # Got started without arguments
  exec n8n
fi
