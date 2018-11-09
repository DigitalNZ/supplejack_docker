FROM ruby:2.3.1 as base

# run system updates install system dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

RUN mkdir -p /var/api

FROM base as test

# Installing Gems
COPY Gemfile* /tmp/
WORKDIR /tmp

RUN NOKOGIRI_USE_SYSTEM_LIBRARIES=1 bundle install

WORKDIR /var/api

COPY . .

EXPOSE 3000

CMD bundle exec puma -C config/puma.rb