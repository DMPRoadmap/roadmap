#
# NOTE:
#
# This Dockerfile is meant for running the application in an AWS ECS container. The required
# Rails credentials and ENV variables are all defined by the CloudFormation template and passed
# into the container on startup
FROM ruby:3.0

RUN echo $(apt-cache search magick)

# Add NodeJS and Yarn repositories to apt-get
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
# Installing Node 16.x
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash

# Install packages
RUN apt-get clean
RUN apt-get -qqy update \
    && apt-get install -y vim \
                          build-essential \
                          git \
                          curl \
                          locales \
                          libreadline-dev \
                          libssl-dev \
                          libsqlite3-dev \
                          wget \
                          imagemagick \
                          xz-utils \
                          libcurl4-gnutls-dev \
                          libxrender1 \
                          libfontconfig1 \
                          apt-transport-https \
                          tzdata \
                          xfonts-base \
                          xfonts-75dpi \
                          yarn \
		                  python \
                          shared-mime-info \
		                  nodejs -qqy \
                          chromium \
    && rm -rf /var/lib/apt/lists/*

# Always run Node in Production for the ECS hosted environments
ENV NODE_ENV=production

RUN echo Using RAILS_ENV: ${RAILS_ENV}, NODE_ENV: ${NODE_ENV}

COPY . /application/
WORKDIR /application

# Ensure its using the timezone we want
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Clear out any old Gem and JS dependencies that might be in the image
RUN rm -rf node_modules vendor

# Install Bundler
RUN gem install bundler

RUN mkdir pid

# Copy the credentials that CodeBuild created and placed in the ./docker directory
COPY docker/credentials.yml.enc ./config/

# Copy over the upgrade script and run the tasks (db migration, rake tasks, etc.)
# COPY --chown=755 docker/upgrade.sh ./upgrade.sh
# RUN ./upgrade.sh

# Rails requires the Spring preloader to run migrations and to compile our assets, so run
# those tasks in development mode
# ENV RAILS_ENV=development
# RUN bundle config set without 'pgsql thin rollbar test'
# RUN bundle install --jobs 20 --retry 5

# RUN bin/rails assets:clobber
# RUN bin/rails assets:precompile

# Now that we're done with the migrations, asset compilation and upgrade tasks, we can rebuild the
# bundle for production
RUN rm -rf vendor
ENV RAILS_ENV=production
RUN bundle config set without 'pgsql thin rollbar development test'
RUN bundle install --jobs 20 --retry 5
RUN yarn --frozen-lockfile --production && yarn install

# expose correct ports
#   25 - email server
#   80 and 443 - HTTP traffic
#   3306 - database server
EXPOSE 25 80 443 3306

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-p", "80"]
