# release: rake db:migrate
web: bundle exec puma -C config/puma.rb -e production
cable: bundle exec puma -p 28080 cable/config.ru -e production
