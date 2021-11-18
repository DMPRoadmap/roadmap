#!/bin/bash
set -u

#Timezone
export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export PASSENGER_DOWNLOAD_NATIVE_SUPPORT_BINARY=0
export RAILS_ENV=production

ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

# Additionnal DB actions
# bundle exec rake db:seed
bundle exec rake db:migrate
RAILS_ENV=$RAILS_ENV bundle exec rake assets:precompile
#bundle exec rake load_templates

# Start the app
# bundle exec rails s -e $RAILS_ENV -p 3000 -b 0.0.0.0
nginx -c /etc/nginx/nginx.conf -t
chmod 666 /var/log/nginx/production.log
service nginx start
