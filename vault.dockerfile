FROM vault:latest

COPY ["volumes", "/vault"]


# Install build tools
RUN apk add --update alpine-sdk \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget  https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk \
    && apk update \
    && apk add glibc-2.34-r0.apk \
    && apk add linux-headers \
    && apk add go git openssl

# Add required packages
RUN apk add --no-cache --upgrade bash
RUN apk add --no-cache jq httpie

# Configure Go
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH

# Download and build plugin
RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin \
    && cd /vault \
    && git clone https://github.com/immutability-io/vault-ethereum.git \
    && cd vault-ethereum \
    && go build
    
# RUN chmod +x /vault/initialize-vault.sh 
RUN chmod a+x /vault/scripts/main/create-initial-users.sh
RUN chmod a+x /vault/scripts/main/unseal-vault.sh
RUN chmod a+x /vault/scripts/main/demo.sh


ENV VAULT_ADDR https://127.0.0.1:9200 
ENV VAULT_CACERT /vault/certs/root.crt
EXPOSE 9200