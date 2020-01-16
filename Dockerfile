FROM nginx:1.17.7-alpine AS builder

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN apk add --no-cache --virtual .build-deps \
  gcc \
  libc-dev \
  make \
  openssl-dev \
  pcre-dev \
  zlib-dev \
  linux-headers \
  curl \
  gnupg \
  libxslt-dev \
  gd-dev \
  geoip-dev \
  git

# nginx:alpine contains NGINX_VERSION environment variable, like so:
# ENV NGINX_VERSION 1.15.0

# Download sources
RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
  git clone --recurse-submodules  "https://github.com/google/ngx_brotli.git" brotli
RUN mkdir -p /usr/src
# Reuse same cli arguments as the nginx:alpine image used to build
RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
	tar -zxC /usr/src -f nginx.tar.gz && \
	cd './brotli' && BROTLIDIR="$(pwd)" && \
  cd /usr/src/nginx-$NGINX_VERSION && \
  ./configure --with-compat $CONFARGS --add-dynamic-module=$BROTLIDIR && \
  make && make install


# ------------------------------------------------------------------------------------------ #

FROM nginx:1.17.7-alpine

COPY --from=builder /usr/local/nginx/modules/ngx_http_brotli_filter_module.so /usr/local/nginx/modules/ngx_http_brotli_filter_module.so
COPY --from=builder /usr/local/nginx/modules/ngx_http_brotli_static_module.so /usr/local/nginx/modules/ngx_http_brotli_static_module.so

RUN mkdir -p /var/www/app/
WORKDIR /var/www/app/
COPY /nginx.conf /etc/nginx/
COPY /default.conf /etc/nginx/conf.d/default.conf
COPY index.html .

CMD ["nginx", "-g", "daemon off;"]
