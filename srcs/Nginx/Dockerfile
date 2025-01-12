FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx openssl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY nginx.conf /etc/nginx/nginx.conf
COPY ssl/ /etc/nginx/ssl/

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]


