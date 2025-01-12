# Utilizamos una imagen oficial de Ubuntu
FROM ubuntu:latest

# Damos información sobre la imagen que estamos creando
LABEL \
    version="1.0" \
    description="Ubuntu + Apache2 + virtual host" \
    maintainer="Oscar Prieto <oprieto@birt.eus>"

# Actualizamos la lista de paquetes e instalamos nano, apache2 y el servidor proftpd
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y nano apache2 && \
    apt-get install openssl && \
    apt-get install -y proftpd && \
    apt-get install -y proftpd-mod-crypto && \
    apt-get install -y sudo openssh-server && \
    rm -rf /var/lib/apt/lists/* 


# Cambiamos el puerto de escucha del servidor ssh
#RUN sed -i 's/Port 22/Port 2222/g' /etc/ssh/sshd_config

# Creamos el usuario oskar1 y oskar2 con password deaw
RUN useradd -m -d  /var/www/html/sitioprimero -s /sbin/nologin oskar1
RUN echo "oskar1:deaw" | chpasswd
RUN useradd -rm -d /var/www/html/sitiosegundo -s /bin/bash oskar2 && \
    echo 'oskar2:deaw' | chpasswd
RUN groupadd ftpusers
RUN usermod -aG ftpusers oskar1
RUN chmod 755 /var/www/html/sitiosegundo


# Creamos directorios para los sitios web y configuraciones
RUN mkdir -p /var/www/html/sitioprimero /var/www/html/sitiosegundo && \
    mkdir /var/run/sshd 


# Copiamos archivos al contenedor
COPY indexprimero.html indexsegundo.html sitioprimero.conf sitiosegundo.conf sitioprimero.key sitioprimero.cer /


# Movemos los archivos a sus ubicaciones adecuadas
RUN mv /indexprimero.html /var/www/html/sitioprimero/index.html && \
    mv /indexsegundo.html /var/www/html/sitiosegundo/index.html && \
    mv /sitioprimero.conf /etc/apache2/sites-available/sitioprimero.conf && \
    mv /sitiosegundo.conf /etc/apache2/sites-available/sitiosegundo.conf && \
    mv /sitioprimero.key /etc/ssl/private/sitioprimero.key && \
    mv /sitioprimero.cer /etc/ssl/certs/sitioprimero.cer

RUN chmod 755 /var/www/html/sitioprimero && chmod 775 /var/www/html/sitiosegundo

    # Habilitamos los sitios y el módulo SSL
RUN a2ensite sitioprimero.conf && \
    a2ensite sitiosegundo.conf && \
    a2enmod ssl


# Copiamos nuestros archivos al contenedor creando las carpetas
COPY Entrega/proftpd.conf /etc/proftpd/proftpd.conf
COPY Entrega/tls.conf /etc/proftpd/tls.conf
COPY Entrega/modules.conf /etc/proftpd/modules.conf
COPY Entrega/proftpd.pem /etc/ssl/certs/proftpd.pem
COPY Entrega/proftpd.key /etc/ssl/private/proftpd.key
COPY Entrega/sshd_config /etc/ssh/sshd_config
RUN chmod 640 /etc/ssl/certs/proftpd.pem
RUN chmod 640 /etc/ssl/private/proftpd.key



# Exponemos los puertos para http, https, ssh y ftp
EXPOSE 80
EXPOSE 443
EXPOSE 22
EXPOSE 21
EXPOSE 50000:50030

# Comando por defecto al iniciar el contenedor (un script de inicio para ambos servicios)
COPY Entrega/inicio.sh /
RUN chmod +x /inicio.sh
CMD ["/inicio.sh"]
