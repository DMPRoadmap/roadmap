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

# Env variables for application
ENV DB_ADAPTER=mysql2
ENV NODE_ENV=production
ENV RAILS_SERVE_STATIC_FILES=false

COPY . /application/
WORKDIR /application

# Ensure its using the timezone we want
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install Bundler
RUN gem install bundler
RUN bundle config set without 'pgsql thin rollbar'
RUN mkdir pid

# Load dependencies
RUN bundle install --jobs 20 --retry 5

# Install and run Yarn
# RUN npm install -g yarn
RUN rm -rf node_modules
RUN yarn --frozen-lockfile --production
# RUN yarn install

# Copy the custom config files for Docker
COPY docker/config/database.yml config/database.yml
COPY docker/config/webpacker.yml config/webpacker.yml
COPY docker/config/environments/ci.rb config/environments/ci.rb
COPY docker/config/initializers/dragonfly.rb config/initializers/dragonfly.rb
COPY docker/config/initializers/wicked_pdf.rb config/initializers/wicked_pdf.rb
COPY docker/config/webpack/ci.js config/webpack/ci.js

# Add the wkhtmltopdf path to the ENV variables
RUN export WICKED_PDF_PATH=`which wkhtmltopdf`
RUN echo $WICKED_PDF_PATH

# Copy the startup script into the container
COPY --chown=755 docker/startup.rb ./startup.rb

# expose correct ports
#   25 - email server
#   80 and 443 - HTTP traffic
#   3306 - database server
EXPOSE 25 80 443 3306

CMD ["ruby", "startup.rb"]
