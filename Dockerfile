FROM ruby:2.3.1-alpine
MAINTAINER Colin Fleming <c3flemin@gmail.com> 

# configure environment variable
ENV DCAF_DIR=/usr/src/app

# get our gem house in order
RUN mkdir -p ${DCAF_DIR}
WORKDIR ${DCAF_DIR}
COPY Gemfile ${DCAF_DIR}
COPY Gemfile.lock ${DCAF_DIR}

# install packages
RUN apk add --update \
    build-base \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    nodejs && \
    gem install bundler --no-ri --no-rdoc && \
    cd ${DCAF_DIR} ; bundle install --without development test && \
    apk del build-base && \
    rm -rf /var/cache/apk/*

# symlink which nodejs to node
RUN ln -s `which nodejs` /usr/bin/node

# install phantomjs
RUN npm install -g phantomjs-prebuilt

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN addgroup dcaf && adduser -s /bin/bash -D -G dcaf dcaf
RUN chown -R dcaf:dcaf ${DCAF_DIR}
USER dcaf
WORKDIR ${DCAF_DIR}

COPY . ${DCAF_DIR}

EXPOSE 3000
