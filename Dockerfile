FROM phusion/passenger-ruby24:1.0.19

LABEL maintainer="Benjamin FAURE benjamin.faure@inist.fr"

# Setting some env vars
ENV HOME=/root \
    PASSENGER_DOWNLOAD_NATIVE_SUPPORT_BINARY=0 \
    LANGUAGE=fr_FR.UTF-8 \
    LANG=fr_FR.UTF-8 \
    LC_ALL=fr_FR.UTF-8 \
    RUBY_VERSION=2.4.10


# Addin Yarn repo
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Installing package dependencies
RUN apt-get -qqy update \
    && apt-get install vim \
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
    ca-certificates -qqy \
    && rm -rf /var/lib/apt/lists/*

# Installing Node 10.x
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash
RUN apt install -y nodejs

# Set locale to UTF8
RUN locale-gen --no-purge fr_FR.UTF-8 \
    && update-locale LANG=fr_FR.UTF-8 \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# Copying project files
COPY . /dmponline

WORKDIR /dmponline

# Installing Ruby and Node dependencies
RUN echo $RUBY_VERSION > .ruby-version \
    && gem install bundler -v 1.17.3 \
    && echo 'gem "tzinfo-data"' >> Gemfile \
    # && bundle install --without mysql puma thin
    && bundle install --without mysql
RUN yarn

RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.focal_amd64.deb \
    && apt install ./wkhtmltox_0.12.6-1.focal_amd64.deb

# Run the app using the rails.sh script
COPY ./rails.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/rails.sh
# RUN mkdir -p /dmponline/public/system/dragonfly && chmod a+rw  -R /dmponline/public/system/dragonfly
CMD ["rails.sh"]
