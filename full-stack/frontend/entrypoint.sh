#!/bin/bash

# Pornește serverul SSH în background
/usr/sbin/sshd -D &

# Verifică dacă node_modules există. Dacă nu, rulează npm install.
# Acest lucru se va întâmpla doar la prima pornire a containerului.
if [ ! -d "node_modules" ]; then
  echo "Folderul node_modules nu a fost găsit, se rulează npm install..."
  npm install
fi

# Pornește serverul de dezvoltare Next.js în prim-plan
# 'exec' face ca procesul npm să devină procesul principal,
# permițând ca semnalele (ex: Ctrl+C) să fie primite corect.
echo "Se pornește serverul de dezvoltare Next.js..."
exec npm run dev -- -H 0.0.0.0