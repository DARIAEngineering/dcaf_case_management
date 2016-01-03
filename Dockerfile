FROM rails:4.2.5
MAINTAINER Colin Fleming <c3flemin@gmail.com> 

# install packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app
