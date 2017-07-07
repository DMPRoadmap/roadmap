# create DMP_roadmap container from source.

FROM ruby:2.3.4

RUN mkdir /app
WORKDIR /app

ADD Gemfile /app/
ADD . /app
RUN cd /app && bundle install
