 #!/bin/sh
  set -eu

  : "${PROXY_API_KEY:?Please set PROXY_API_KEY}"
  : "${MANAGEMENT_PASSWORD:?Please set MANAGEMENT_PASSWORD}"

  mkdir -p /root/.cli-proxy-api /CLIProxyAPI/logs /run/nginx

  cat > /CLIProxyAPI/config.yaml <<EOF
  host: "127.0.0.1"
  port: 8318
  auth-dir: "/root/.cli-proxy-api"
  debug: false
  request-retry: 3

  api-keys:
    - "${PROXY_API_KEY}"

  remote-management:
    allow-remote: true
    secret-key: "${MANAGEMENT_PASSWORD}"

  routing:
    strategy: "round-robin"
  EOF

  cat > /etc/nginx/http.d/default.conf <<'NGINX'
  server {
      listen 8317;
      server_name _;

      client_max_body_size 100m;
      proxy_read_timeout 3600s;
      proxy_send_timeout 3600s;

      location = / {
          add_header Content-Type text/plain;
          return 200 "OK\n";
      }

      location = /health {
          add_header Content-Type text/plain;
          return 200 "OK\n";
      }

      location / {
          proxy_pass http://127.0.0.1:8318;
          proxy_http_version 1.1;

          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
      }
  }
  NGINX

  echo "Starting CLIProxyAPI on 127.0.0.1:8318..."
  /CLIProxyAPI/CLIProxyAPI --config /CLIProxyAPI/config.yaml &
  APP_PID=$!

  sleep 2

  if ! kill -0 "$APP_PID" 2>/dev/null; then
      echo "CLIProxyAPI exited early. Check logs above."
      wait "$APP_PID"
  fi

  echo "Starting Nginx on 0.0.0.0:8317..."
  nginx -g 'daemon off;' &
  NGINX_PID=$!

  while kill -0 "$APP_PID" 2>/dev/null && kill -0 "$NGINX_PID" 2>/dev/null; do
      sleep 2
  done

  echo "One of the processes exited. Stopping container..."
  kill "$APP_PID" "$NGINX_PID" 2>/dev/null || true
  wait "$APP_PID" 2>/dev/null || true
  wait "$NGINX_PID" 2>/dev/null || true
  exit 1
