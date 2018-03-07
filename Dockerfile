FROM openresty/openresty:alpine

COPY conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY conf/spaces.conf /etc/nginx/conf.d/default.conf
COPY conf/error.html /usr/local/openresty/nginx/html
COPY lua/ /usr/local/openresty/lib/lua

VOLUME /var/cache/nginx
EXPOSE 80

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]
