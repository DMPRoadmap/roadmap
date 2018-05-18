# create DMP_roadmap container from source.

FROM ruby:2.3.4

RUN gem install bundler
ENV APP_ROOT /app
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

COPY Gemfile Gemfile.lock $APP_ROOT/
RUN bundle install --jobs=3 --retry=3

COPY . $APP_ROOT

EXPOSE 3000
