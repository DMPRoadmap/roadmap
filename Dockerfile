FROM ruby:2.5
LABEL maintainer="University of Alberta Libraries"

# install dependencies
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - 
RUN apt-get install -y nodejs
RUN apt-get install -y imagemagick
RUN apt-get install -y mariadb-client 
RUN npm install --global yarn

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

ENV APP_ROOT /app
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

COPY Gemfile Gemfile.lock $APP_ROOT/
RUN gem install bundler
RUN bundle install --jobs=3 --retry=3

# *NOW* we copy the codebase in
COPY . $APP_ROOT

EXPOSE 3000
