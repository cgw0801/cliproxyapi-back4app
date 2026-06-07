FROM --platform=linux/amd64 docker.io/eceasy/cli-proxy-api:latest

WORKDIR /CLIProxyAPI

COPY start.sh /CLIProxyAPI/start.sh
RUN chmod +x /CLIProxyAPI/start.sh

EXPOSE 8317

CMD ["/CLIProxyAPI/start.sh"]
