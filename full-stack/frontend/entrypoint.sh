#!/bin/bash

# Pornește serverul SSH în background
/usr/sbin/sshd -D &

# Trecem direct la pornirea serverului de dezvoltare
# Acum folosește scriptul "dev" modificat din package.json
echo "Se pornește serverul de dezvoltare Next.js pe 0.0.0.0..."
exec npm run dev