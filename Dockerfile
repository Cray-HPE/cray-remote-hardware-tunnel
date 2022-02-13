FROM artifactory.algol60.net/csm-docker/stable/docker.io/library/alpine
RUN apk update && \
    apk -U upgrade && \
    apk add --upgrade \
        apk-tools \
        build-base \
        cairo \
        cairo-dev \
        cargo \
        freetype-dev \
        gcc \
        gdk-pixbuf-dev \
        gettext \
        jpeg-dev \
        lcms2-dev \
        libffi-dev \
        linux-headers \
        musl-dev \
        openjpeg-dev \
        openssl-dev \
        pango-dev \
        poppler-utils \
        py-cffi \
        rust \
        tcl-dev \
        tiff-dev \
        tk-dev \
        zlib-dev \
        py3-pip=~20 python3-dev=~3.9 \
        openssh-client-default && \
    rm -rf /var/cache/apk/*
RUN mkdir -p /opt/cray
COPY [ ".", "/opt/cray" ]
RUN pip3 install --no-cache-dir -r /opt/cray/requirements.txt
EXPOSE 22
EXPOSE 443
WORKDIR /opt/cray
ENTRYPOINT /opt/cray/tunnel_to_endpoint.py
