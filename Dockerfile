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

# Always run Rails and Node in Production for the ECS hosted environments
# Use the other env variables defined in the ECS config in the dmp-hub-cfn repo to tailor
# specific functionality (e.g. RAILS_LOG_LEVEL, RAILS_SERVE_STATIC_FILES, etc.)
ENV RAILS_ENV=production
ENV NODE_ENV=production

RUN echo Using RAILS_ENV: ${RAILS_ENV}, NODE_ENV: ${NODE_ENV}

COPY . /application/
WORKDIR /application

# Ensure its using the timezone we want
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install Bundler
RUN gem install bundler
# RUN bin/rails db:environment:set RAILS_ENV=$RAILS_ENV
RUN bundle config set without 'pgsql thin rollbar development test'
RUN mkdir pid

# Clear out any old Gem and JS dependencies that might be in the image
RUN rm -rf node_modules vendor

# Load dependencies
RUN bundle lock --add-platform x86_64-linux && bundle install --jobs 20 --retry 5
RUN yarn --frozen-lockfile --production && yarn install

# Copy the credentials
COPY docker/master.key ./config/
COPY docker/credentials.yml.enc ./config/

# Copy the startup script into the container
COPY --chown=755 docker/startup.rb ./startup.rb

# expose correct ports
#   25 - email server
#   80 and 443 - HTTP traffic
#   3306 - database server
EXPOSE 25 80 443 3306

CMD ["ruby", "startup.rb"]
