FROM ruby:3.1.3 as dev
WORKDIR /app
COPY . .
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt install -y nodejs && \
  apt install -y \
    postgresql-client \
    wkhtmltopdf \
    imagemagick \
    tzdata && \
  ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
  ln -sf /usr/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf && \
  echo 'gem "tzinfo-data"' >> ./Gemfile && \
  echo 'gem "net-smtp"' >> ./Gemfile && \
  gem install pg puma net-smtp && \
  gem install bundler -v 2.4.8 && \
  bundle install && \
  npm i -g yarn

FROM dev as production
COPY . .
RUN DISABLE_SPRING=1 NODE_OPTIONS=--openssl-legacy-provider yarn build && \
    NODE_OPTIONS=--openssl-legacy-provider yarn build:css && \
    rm -rf node_module

FROM ruby:3.1.3-alpine3.17
WORKDIR /app
COPY --from=production /app .
RUN apk add --no-cache --update --virtual \
  build-dependencies \
  build-base \
  tzdata \
  postgresql-dev \
  imagemagick && \
  echo 'https://dl-cdn.alpinelinux.org/alpine/v3.14/community' >> /etc/apk/repositories && \
  echo 'https://dl-cdn.alpinelinux.org/alpine/v3.14/main' >> /etc/apk/repositories && \
  apk add --no-cache wkhtmltopdf && \
  ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
  ln -sf /usr/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf && \
  chmod +x /usr/local/bin/wkhtmltopdf && \
  echo 'gem "tzinfo-data"' >> ./Gemfile && \
  echo 'gem "net-smtp"' >> ./Gemfile && \
  gem install pg puma net-smtp && \
  gem install bundler -v 2.4.8 && \
  bundle config set --local without 'mysql thin test ci aws development' && \
  bundle install
EXPOSE 3000
CMD [ "bundle", "exec", "puma", "-C", "/app/config/puma.rb", "-e", "production" ]