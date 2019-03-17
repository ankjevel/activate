FROM openresty/openresty:1.15.8.1rc1-alpine

COPY src/nginx.conf /usr/local/openresty/nginx/conf/
COPY src/actions /usr/local/openresty/nginx/conf/actions
COPY src/conf.d /usr/local/openresty/nginx/conf/conf.d
COPY src/lua /usr/local/openresty/nginx/conf/lua
COPY src/sites-enabled /usr/local/openresty/nginx/conf/sites-enabled
COPY src/temp /usr/local/openresty/nginx/conf/temp
