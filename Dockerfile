FROM ruby:2.4.4

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
RUN bundle update rake
# install yarn+node from packages
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get install -y nodejs
RUN apt-get update && apt-get install -y yarn
RUN wget --quiet https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz && \
    tar vxf wkhtmltox-0.12.3_linux-generic-amd64.tar.xz && \
    cp wkhtmltox/bin/wk* /usr/local/bin/ && \
    rm -rf wkhtmltox


# expose correct port
EXPOSE 3000
