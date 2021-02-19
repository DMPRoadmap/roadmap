FROM phusion/passenger-ruby24:1.0.12

MAINTAINER Benjamin FAURE <benjamin.faure@inist.fr>

ENV HOME=/root \
    PASSENGER_DOWNLOAD_NATIVE_SUPPORT_BINARY=0 \
    LANGUAGE=fr_FR.UTF-8 \
    LANG=fr_FR.UTF-8 \
    LC_ALL=fr_FR.UTF-8 \
    RUBY_VERSION=2.4.10


RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
# RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

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
		       nodejs \
                       ca-certificates -qqy \
    && rm -rf /var/lib/apt/lists/*

# WKHTMLTOPDF
RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb \
    && dpkg -i wkhtmltox_0.12.5-1.bionic_amd64.deb \
    && apt-get install -f

# Set locale to UTF8
RUN locale-gen --no-purge fr_FR.UTF-8 \
    && update-locale LANG=fr_FR.UTF-8 \
    && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

ENV DMPOPIDOR_VERSION=0.0.68-dev
RUN mkdir /dmponline
RUN git config --system http.proxy $http_proxy \ 
    && git config --global user.email "benjamin.faure@inist.fr" \
    && git config --global user.name "Benjamin FAURE" \
    && git config --global url."https://".insteadOf git://
WORKDIR /dmponline
RUN git clone http://vxgit.intra.inist.fr:60000/git/opidor/dmpopidor.git . \
    && git checkout tags/$DMPOPIDOR_VERSION  

WORKDIR /dmponline
#Dependences Ruby
RUN echo $RUBY_VERSION > .ruby-version \
    && gem install bundler -v 1.17.3 \
    && echo 'gem "tzinfo-data"' >> Gemfile \
    && bundle install --without mysql puma thin

COPY ./rails.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/rails.sh
RUN mkdir -p /dmponline/public/system/dragonfly && chmod a+rw  -R /dmponline/public/system/dragonfly
CMD ["rails.sh"]
