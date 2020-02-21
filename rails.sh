#!/bin/bash

bundle exec rake db:drop
bundle exec rake db:create
bundle exec rake db:schema:load
bundle exec rake db:migrate
bundle exec rails s -e development -p 3000 -b 0.0.0.0

# #!/bin/bash
# set -u


# #Timezone
# export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
# export PASSENGER_DOWNLOAD_NATIVE_SUPPORT_BINARY=0
# ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
# dpkg-reconfigure --frontend noninteractive tzdata
# # Vérification de l'initialisation de la base
# if [ ! -f /dmponline/db/.dbinit/.temoin ] ; then
#   # if bundle exec rake db:setup --trace RAILS_ENV=$RAILS_ENV ; then
#   if bundle exec rake db:create && rake db:schema:load && rake db:migrate ; then
#     touch /dmponline/db/.dbinit/.temoin
#   fi
# fi

# # Création des certifs SSL si le serveur est de prod
# if [ $RAILS_ENV == "production" ] ; then
#   # Si la clé n'existe pas, on la crée
#   if [ ! -f /dmponline/.ssl/localhost.key ] ; then
#   openssl req -new -newkey rsa:2048 -sha1 \
#           -subj "/CN=`hostname`" \
#           -days 365 -nodes -x509 -keyout ./.ssl/localhost.key -out ./.ssl/localhost.crt

#   fi
#   # On copie la clé au bon endroit
#   cp ./.ssl/localhost.key /etc/ssl/certs
#   cp ./.ssl/localhost.crt /etc/ssl/certs
#   echo "127.0.0.1 `hostname`" | tee -a /etc/hosts
#   #RAILS_ENV=$RAILS_ENV bundle exec rake db:migrate
#   RAILS_ENV=$RAILS_ENV bundle exec rake assets:precompile
#   # Démarrage du serveur en SSL avec l'emplacement des clés
#  # bundle exec thin start -p 3001 --ssl --ssl-key-file /etc/ssl/certs/localhost.key --ssl-cert-file /etc/ssl/certs/localhost.crt
#   #bundle exec rails server -p 3001 -e $RAILS_ENV
#   nginx -c /etc/nginx/nginx.conf -t
#   chmod 666 /var/log/nginx/production.log
#   service nginx start
# else
#   sleep 2h
#   #bundle exec rails server -p 40000 

# fi
