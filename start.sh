#!/bin/sh
  set -eu

  : "${PROXY_API_KEY:?Please set PROXY_API_KEY}"
  : "${MANAGEMENT_PASSWORD:?Please set MANAGEMENT_PASSWORD}"

  cat > /CLIProxyAPI/config.yaml <<EOF
  host: "0.0.0.0"
  port: 8317
  auth-dir: "/root/.cli-proxy-api"
  debug: false
  request-retry: 3

  api-keys:
    - "${PROXY_API_KEY}"

  remote-management:
    allow-remote: true
    secret-key: "${MANAGEMENT_PASSWORD}"
  EOF

  exec /CLIProxyAPI/CLIProxyAPI
