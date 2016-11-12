FROM rails:4.2.6
MAINTAINER Colin Fleming <c3flemin@gmail.com> 

# configure environment variable
ENV DCAF_DIR=/usr/src/app

# install packages
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \ 
    libxml2-dev \
    libxslt1-dev \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# symlink which nodejs to node
RUN ln -s `which nodejs` /usr/bin/node

# install phantomjs
RUN npm install -g phantomjs-prebuilt

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN groupadd -r dcaf && useradd -r -g dcaf dcaf
RUN mkdir -p ${DCAF_DIR} && chown -R dcaf ${DCAF_DIR} && chgrp -R dcaf ${DCAF_DIR}
USER dcaf
WORKDIR ${DCAF_DIR}
COPY Gemfile ${DCAF_DIR}
COPY Gemfile.lock ${DCAF_DIR}
RUN bundle install

COPY . ${DCAF_DIR}
