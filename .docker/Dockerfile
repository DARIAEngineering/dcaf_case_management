FROM ruby:2.6.2-alpine
MAINTAINER Colin Fleming <c3flemin@gmail.com>

# configure environment variable
# note: move this to three ARG commands when CircleCI updates their docker
ENV DCAF_DIR=/usr/src/app \
    BUILD_DEPENDENCIES="build-base libxml2-dev libxslt-dev linux-headers bash openssh fontconfig fontconfig-dev curl" \
    APP_DEPENDENCIES="nodejs git nodejs-npm sassc" \
    FONTCONFIG_PATH=/etc/fonts \
    NODE_ENV=development \
    DOCKER=true

# get our gem house in order
RUN mkdir -p ${DCAF_DIR} && cd ${DCAF_DIR}
WORKDIR ${DCAF_DIR}
COPY Gemfile ${DCAF_DIR}/Gemfile
COPY Gemfile.lock ${DCAF_DIR}/Gemfile.lock
COPY package.json ${DCAF_DIR}/package.json
COPY yarn.lock ${DCAF_DIR}/yarn.lock

# install packages
RUN apk update && apk upgrade && \
    apk add --no-cache \
    ${BUILD_DEPENDENCIES} \
    ${APP_DEPENDENCIES} && \
    gem install bundler --no-document && \
    npm install -g yarn

# symlink which nodejs to node
RUN ln -s `which nodejs` /usr/bin/node

# install gemfile and package
RUN bundle install
RUN yarn install

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

# remove unnecessary dependencies
RUN apk del ${BUILD_DEPENDENCIES}

# Move the rest of the app over
COPY . ${DCAF_DIR}

EXPOSE 3000
