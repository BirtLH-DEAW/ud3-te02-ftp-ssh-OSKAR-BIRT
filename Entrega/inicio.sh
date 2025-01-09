#!/bin/bash

# Iniciar ProFTPD en primer plano
/usr/sbin/proftpd &

# Iniciar Apache2 en primer plano
/usr/sbin/apache2ctl -D FOREGROUND
