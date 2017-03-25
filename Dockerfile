FROM ruby:2.4.1-alpine
MAINTAINER Colin Fleming <c3flemin@gmail.com> 

# configure environment variable
# note: move this to three ARG commands when CircleCI updates their docker
ENV DCAF_DIR=/usr/src/app \
    BUILD_DEPENDENCIES="build-base libxml2-dev libxslt-dev linux-headers bash git openssh" \
    APP_DEPENDENCIES="nodejs"

# get our gem house in order
RUN mkdir -p ${DCAF_DIR} && cd ${DCAF_DIR}
WORKDIR ${DCAF_DIR}
COPY Gemfile ${DCAF_DIR}/Gemfile
COPY Gemfile.lock ${DCAF_DIR}/Gemfile.lock

# install packages
RUN apk update && apk upgrade && \
    apk add --no-cache \
    ${BUILD_DEPENDENCIES} \
    ${APP_DEPENDENCIES} && \
    gem install bundler --no-ri --no-rdoc && \
    cd ${DCAF_DIR} ; bundle install && \
    apk del ${BUILD_DEPENDENCIES} 

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
