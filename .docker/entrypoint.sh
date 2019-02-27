#!/bin/sh
start_server() {
    rails s -p 3000 -b 0.0.0.0
}

if bundle check; then
    yarn install && start_server
else
    bundle install && yarn install && start_server
fi
