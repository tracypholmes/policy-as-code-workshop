FROM ubuntu

ENV VERSION=0.21.0

RUN apt-get update && \
    apt-get install -y wget=1.20.3-1ubuntu1 unzip=6.0-25ubuntu1 && \
    wget -q https://github.com/nicholasjackson/fake-service/releases/download/v${VERSION}/fake_service_linux_amd64.zip && \
    unzip fake_service_linux_amd64.zip && \
    chmod +x fake-service && \
    mv fake-service /usr/local/bin && \
    groupadd ubuntu && \
    useradd -rm -d /home/ubuntu -s /bin/sh -g ubuntu -u 1001 ubuntu && \
    chown ubuntu /usr/local/bin/fake-service && \
    rm -rf /var/lib/apt/lists/*

USER ubuntu
WORKDIR /home/ubuntu

CMD ["/usr/local/bin/fake-service"]