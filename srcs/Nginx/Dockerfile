FROM debian:bullseye

# Actualizar paquetes e instalar nginx, openssl, curl y netcat
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    curl \
    netcat && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiar la configuración de nginx y los certificados SSL
COPY nginx.conf /etc/nginx/nginx.conf
COPY ssl/ /etc/nginx/ssl/

# Exponer el puerto 443
EXPOSE 443

# Comando para iniciar nginx
CMD ["nginx", "-g", "daemon off;"]



