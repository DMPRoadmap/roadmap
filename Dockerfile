FROM ruby:3.1.4-slim as base
WORKDIR /app
RUN apt update -y && apt install -y \
    build-essential \
    wget \
    libpq-dev \
    wkhtmltopdf \
    imagemagick \
    tzdata \
    gnupg2 && \
  wget -qO- https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt update -y && apt install -y yarn && \
  apt clean && \
  rm -rf /var/lib/apt/lists/* && \
  ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
  ln -sf /usr/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf && \
  chmod +x /usr/local/bin/wkhtmltopdf

FROM base as dev
COPY . .
RUN wget -qO- https://deb.nodesource.com/setup_18.x | bash - && \
  apt update -y && apt install -y \
    nodejs && \
  echo 'gem "tzinfo-data"' >> ./Gemfile && \
  echo 'gem "net-smtp"' >> ./Gemfile && \
  gem install pg puma net-smtp && \
  gem install bundler -v 2.4.15 && \
  bundle config set --local without 'mysql' && \
  bundle install && \
  yarn install

FROM dev as build
ARG DB_ADAPTER \
  DB_USERNAME \
  DB_PASSWORD
RUN bin/docker ${DB_ADAPTER:-postgres} && \
  RAILS_ENV=build DISABLE_SPRING=1 NODE_OPTIONS=--openssl-legacy-provider rails assets:precompile && \
  rm -rf node_modules

FROM base as production
COPY --from=build /app .
RUN bundle config set --local without 'mysql thin test ci aws development build' && \
  bundle install
EXPOSE 3000
CMD [ "bundle", "exec", "puma", "-C", "/app/config/puma.rb", "-e", "production" ]
