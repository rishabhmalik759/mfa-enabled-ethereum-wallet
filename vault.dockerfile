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

# Configure Go
ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH

# Download plugin
RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin \
    && cd /vault \
    && git clone https://github.com/immutability-io/vault-ethereum.git \
    && cd vault-ethereum \
    && go build \
    # && ls -l \ 
    # && ls $GOPATH/bin \
    && cp vault-ethereum ../plugins/ \
    && cd / && rm -r /vault/vault-ethereum \
    && export SHASUM256_eth=$(sha256sum "/vault/plugins/vault-ethereum" | cut -d' ' -f1) \
    && echo $SHASUM256_eth 



CMD /vault/initialize-vault.sh 




# Configure Go
# ENV GOROOT /usr/lib/go
# ENV GOPATH /go
# ENV PATH /go/bin:$PATH

# RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin

# # Install Glide
# RUN go get -u github.com/Masterminds/glide/...

# WORKDIR $GOPATH

# CMD ["make"]