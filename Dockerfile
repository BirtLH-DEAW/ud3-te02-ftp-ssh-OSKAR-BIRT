# Utilizamos una imagen oficial de Ubuntu
FROM ubuntu:latest

# Damos información sobre la imagen que estamos creando
LABEL \
    version="1.0" \
    description="Ubuntu + Apache2 + virtual host" \
    maintainer="usuarioBIRT <usuarioBIRT@birt.eus>"

# Actualizamos la lista de paquetes e instalamos nano, apache2 y el servidor proftpd
RUN apt-get update && \
    apt-get install -y nano apache2 && \
    apt-get install openssl && \
    apt-get install -y proftpd && \
    apt-get install -y proftpd-mod-crypto && \
    rm -rf /var/lib/apt/lists/* 


# Creamos directorios para los sitios web y configuraciones
RUN mkdir -p /var/www/html/sitioprimero /var/www/html/sitiosegundo

# Copiamos archivos al contenedor
COPY indexprimero.html indexsegundo.html sitioprimero.conf sitiosegundo.conf sitioprimero.key sitioprimero.cer /

# Movemos los archivos a sus ubicaciones adecuadas
RUN mv /indexprimero.html /var/www/html/sitioprimero/index.html && \
    mv /indexsegundo.html /var/www/html/sitiosegundo/index.html && \
    mv /sitioprimero.conf /etc/apache2/sites-available/sitioprimero.conf && \
    mv /sitiosegundo.conf /etc/apache2/sites-available/sitiosegundo.conf && \
    mv /sitioprimero.key /etc/ssl/private/sitioprimero.key && \
    mv /sitioprimero.cer /etc/ssl/certs/sitioprimero.cer

# Habilitamos los sitios y el módulo SSL
RUN a2ensite sitioprimero.conf && \
    a2ensite sitiosegundo.conf && \
    a2enmod ssl


# Creamos el usuario oskar1 con password deaw
RUN useradd -m -d  /var/www/html/sitioprimero -s /sbin/nologin oskar1
RUN echo "oskar1:deaw" | chpasswd

# Copiamos nuestros archivos al contenedor creando las carpetas
# RUN mkdir /var/www/html/default_website \
COPY Entrega/proftpd.conf /etc/proftpd/proftpd.conf
COPY Entrega/tls.conf /etc/proftpd/tls.conf
COPY Entrega/modules.conf /etc/proftpd/modules.conf
COPY Entrega/proftpd.pem /etc/ssl/certs/proftpd.pem
COPY Entrega/proftpd.key /etc/ssl/private/proftpd.key
RUN chmod 640 /etc/ssl/certs/proftpd.pem
RUN chmod 640 /etc/ssl/private/proftpd.key



# Exponemos los puertos para http, https y ftp
EXPOSE 80
EXPOSE 443
EXPOSE 21
EXPOSE 50000:50030

# Comando por defecto al iniciar el contenedor (un script de inicio para ambos servicios)
COPY Entrega/inicio.sh /
RUN chmod +x /inicio.sh
CMD ["/inicio.sh"]
