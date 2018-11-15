FROM ruby:2.3.1 as base

# run system updates install system dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev default-jre unzip cron

RUN mkdir -p /var/api

FROM base as test

# Installing Gems
COPY Gemfile* /tmp/
WORKDIR /tmp

RUN gem install bundler
RUN NOKOGIRI_USE_SYSTEM_LIBRARIES=1 bundle install

WORKDIR /var/api
COPY . .

RUN whenever --update-crontab

EXPOSE 3000
EXPOSE 8982

CMD bundle exec puma -C config/puma.rb