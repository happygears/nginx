# Nginx v1.17.6 

Custom nginx image based on nginx:alpine v1.17.6 image with modules builded from source:
- ngx_http_brotli_filter_module.so
- ngx_http_brotli_static_module.so
   
#### Build an image

`
docker build -t happygears/nginx .
`

#### Run image

`docker run -it --rm -p 9944:80 happygears/nginx:latest
`

