
# n8n.io

## Secure, AI-native, workflow automation
Source: [https://n8n.io](https://n8n.io)

### Manual build container
```bash
podman build -t n8n:latest -f ./Dockerfile . --build-arg=N8N_VERSION=latest --build-arg=TARGETPLATFORM="linux/arm64"
```

### Using

Použití vlastních CA certifikátů je možné připojením do adresáře ***/opt/custom-certificates***. Certifikáty musí být ve formátu PEM.

Aplikaci je možné konfigurovat pomocí zdokumentovaných [ENV proměnných](https://docs.n8n.io/hosting/configuration/environment-variables/).
