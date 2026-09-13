FROM ruby:3.4.10-slim-bookworm
LABEL org.opencontainers.image.authors="c3flemin@gmail.com"
LABEL org.opencontainers.image.authors="kathryn.tipton@gmail.com"

## NB: Docekrfiles can cache! Think carefully about where you place commands
## so we don't have to rebuild slow steps unless absolutely necesary

######## SECTION 1: configurations #########

ARG DARIA_DIR=/usr/src/app
ARG BUILD_DEPENDENCIES="build-essential libxml2-dev gnupg2 libxslt-dev fontconfig postgresql libpq-dev libyaml-dev curl"
ARG APP_DEPENDENCIES="git sudo sassc"
ARG FONTCONFIG_PATH=/etc/fonts
ARG NODE_ENV=development
ARG DOCKER=true
ARG NODE_MAJOR=24

WORKDIR ${DARIA_DIR}

######## SECTION 2: installtion ############

# Install system packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y

# Install firefox for system tests, build dependencies, and app dependencies
RUN apt-get install -y firefox-esr # !!!! EXTREMELY SLOW STEP !!!
RUN apt-get install -y ${BUILD_DEPENDENCIES}
RUN apt-get install -y ${APP_DEPENDENCIES}

# Install nodejs
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update
RUN apt-get install nodejs -y

# Set up yarn
RUN corepack enable
RUN yarn set version 3.6.3
RUN yarn config set nodeLinker node-modules

########## SECTION 3: App Dependencies ############

# Ruby Gems
COPY Gemfile ${DARIA_DIR}/Gemfile
COPY Gemfile.lock ${DARIA_DIR}/Gemfile.lock
RUN gem install bundler
RUN bundle install

# Javascript Modules
COPY package.json ${DARIA_DIR}/package.json
COPY yarn.lock ${DARIA_DIR}/yarn.lock
RUN yarn install

# remove unnecessary build dependencies
RUN apt-get purge -y ${BUILD_DEPENDENCIES} && apt-get autoremove -y 

########## SECTION 4: Build the JS and CSS

# Move the rest of the app over
COPY . ${DARIA_DIR}

# Build the js and css
RUN yarn install
RUN yarn build
RUN yarn build:css

EXPOSE 3000
