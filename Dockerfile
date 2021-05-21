FROM ubuntu

ENV VERSION=0.21.0

RUN apt-get update && \
    apt-get install -y wget unzip && \
    wget https://github.com/nicholasjackson/fake-service/releases/download/v${VERSION}/fake_service_linux_amd64.zip && \
    unzip fake_service_linux_amd64.zip && \
    chmod +x fake-service && \
    mv fake-service /usr/local/bin

CMD ["/usr/local/bin/fake-service"]