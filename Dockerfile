FROM ruby:2.3

# Dependancies
RUN apt-get update -qq && \
  apt-get install -y \
  build-essential \
  git \
  libgmp3-dev \
  libpq-dev \
  mysql-client \
  gettext

ARG INSTALL_PATH=/usr/src/app
ENV INSTALL_PATH $INSTALL_PATH

# Setup bundle to install gems to volume
ENV BUNDLE_PATH=/bundle/ \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV Path="${BUNDLE_BIN}:${PATH}"

WORKDIR $INSTALL_PATH
RUN gem install bundler


# expose correct port
EXPOSE 3000
