FROM ruby:2.4.1-alpine
MAINTAINER Colin Fleming <c3flemin@gmail.com> 

# configure environment variable
# note: move this to three ARG commands when CircleCI updates their docker
ENV DCAF_DIR=/usr/src/app \
    BUILD_DEPENDENCIES="build-base libxml2-dev libxslt-dev linux-headers bash openssh fontconfig fontconfig-dev curl" \
    APP_DEPENDENCIES="nodejs git" \
    FONTCONFIG_PATH=/etc/fonts

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
    curl -Ls https://github.com/DarthHater/docker-phantomjs2/releases/download/2.1.1/dockerized-phantomjs.tar.gz | tar xz -C / && \
	phantomjs --version && \
    apk del ${BUILD_DEPENDENCIES} 

# symlink which nodejs to node
RUN ln -s `which nodejs` /usr/bin/node

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR ${DCAF_DIR}

COPY . ${DCAF_DIR}

EXPOSE 3000
