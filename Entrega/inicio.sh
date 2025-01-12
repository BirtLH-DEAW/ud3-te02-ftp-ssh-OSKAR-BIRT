#!/bin/bash

# Iniciar Apache2 en primer plano
/usr/sbin/apache2ctl start

# Iniciar ProFTPD en primer plano
/usr/sbin/proftpd

# Iniciar openssh-server
/usr/sbin/sshd -D

