# Utilizamos una imagen oficial de Ubuntu
FROM ubuntu:latest

# Damos información sobre la imagen que estamos creando
LABEL \
    version="1.0" \
    description="Ubuntu + Apache2 + virtual host" \
    maintainer="usuarioBIRT <usuarioBIRT@birt.eus>"

# Actualizamos la lista de paquetes e instalamos nano y apache2
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nano apache2 && \
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

# Exponemos los puertos
EXPOSE 80
EXPOSE 443

# Comando por defecto al iniciar el contenedor
CMD ["apachectl", "-D", "FOREGROUND"]

