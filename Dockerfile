FROM --platform=linux/amd64 docker.io/eceasy/cli-proxy-api:latest

  USER root

  RUN apk add --no-cache nginx

  WORKDIR /CLIProxyAPI

  COPY start.sh /CLIProxyAPI/start.sh

  RUN chmod +x /CLIProxyAPI/start.sh \
      && mkdir -p /run/nginx /root/.cli-proxy-api /CLIProxyAPI/logs

  EXPOSE 8317

  CMD ["/CLIProxyAPI/start.sh"]
