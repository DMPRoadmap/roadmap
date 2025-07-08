FROM ruby:3.3

ARG INSTALL_PATH=/usr/src/app
ENV INSTALL_PATH=$INSTALL_PATH

# Define bundle paths for both build-time and runtime
ENV GEM_HOME=/bundle
ENV BUNDLE_PATH=/bundle
ENV BUNDLE_BIN=/bundle/bin
ENV PATH="${BUNDLE_BIN}:${PATH}"

# Install base dependencies
RUN apt-get update -qq && \
    apt-get install -y \
      build-essential \
      git \
      libgmp3-dev \
      libpq-dev \
      postgresql-client \
      gettext \
      certbot \
      curl \
      vim \
      ack \
      ca-certificates

# Install Node.js v22 LTS and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get update -qq && \
    apt-get install -y nodejs && \
    corepack enable yarn && \
    corepack prepare yarn@stable --activate && \
    rm -rf /var/lib/apt/lists/*

WORKDIR $INSTALL_PATH

# Copy Gemfile and Gemfile.lock, install Ruby gems
COPY ./Gemfile ./Gemfile.lock ./

RUN gem install bundler && \
    bundle config set without 'mysql thin' && \
    bundle install --jobs=4 --retry=3 --clean

# Copy the rest of the application and install JS dependencies
COPY . .
RUN yarn install

RUN rails assets:clobber
RUN rails assets:precompile


EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
