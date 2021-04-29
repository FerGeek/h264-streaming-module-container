FROM alpine:3.13 as builder
COPY ./tmp/packages ./tmp
RUN cd ~ && tar zxvf /tmp/nginx-1.15.0.tar.gz
RUN cd ~ && tar -zxvf /tmp/nginx_mod_h264_streaming-2.2.7.tar.gz
RUN rm ~/nginx_mod_h264_streaming-2.2.7/src/ngx_http_streaming_module.c
RUN cp /tmp/ngx_http_streaming_module.c ~/nginx_mod_h264_streaming-2.2.7/src/ngx_http_streaming_module.c
RUN rm ~/nginx_mod_h264_streaming-2.2.7/src/mp4_io.c
RUN cp /tmp/mp4_io.c ~/nginx_mod_h264_streaming-2.2.7/src/mp4_io.c
RUN apk update --no-cache
RUN apk add linux-headers
RUN apk add gzip=1.10-r1 pcre-dev=8.44-r0
RUN apk add build-base
RUN apk add zlib-dev=1.2.11-r3 zlib=1.2.11-r3
RUN apk add libpcre32=8.44-r0
RUN apk add openssl-dev
RUN apk add openssl openssl-libs-static
RUN apk add libxslt-dev
RUN apk add gd-dev
RUN apk add g++
RUN apk add make
RUN apk add curl
RUN cd ~/nginx-1.15.0 && ./configure --prefix=/nginx --with-http_ssl_module --with-http_realip_module  --with-http_addition_module  --with-http_xslt_module  --with-http_image_filter_module  --with-http_sub_module --with-http_dav_module --with-http_flv_module  --with-http_mp4_module  --with-http_gzip_static_module  --with-http_random_index_module  --with-http_secure_link_module  --with-http_stub_status_module  --add-module=/root/nginx_mod_h264_streaming-2.2.7
RUN rm ~/nginx-1.15.0/objs/Makefile
RUN cp /tmp/Makefile ~/nginx-1.15.0/objs/Makefile
RUN cd ~/nginx-1.15.0 && make && make install

FROM alpine:3.13
COPY --from=builder /project/nginx-1.15.0 ./nginx/
RUN apk update --no-cache
RUN apk add libxslt-dev gd-dev pcre-dev libxslt-dev
RUN mkdir /nginx/conf/conf.d
RUN mkdir /www
RUN chmod 0755 /nginx/conf/conf.d
RUN chmod 0755 /www
RUN rm /nginx/conf/nginx.conf
COPY ./tmp/conf/nginx.conf /nginx/conf/nginx.conf
COPY ./tmp/conf/default.conf /nginx/conf/conf.d/default.conf
CMD ["./nginx/sbin/nginx"]
EXPOSE 80
