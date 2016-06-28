FROM rails:4.2.6
MAINTAINER Colin Fleming <c3flemin@gmail.com> 

# install packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev 

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
RUN apt-get install -y libqt4-webkit libqt4-dev xvfb

# for a JS runtime
RUN apt-get install -y nodejs && ln -s `which nodejs` /usr/bin/node
RUN apt-get install -y npm

# for phantomjs
RUN npm install -g phantomjs-prebuilt

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app
