#!/bin/sh
start_server() {
    rails s -p 3000 -b 0.0.0.0
}

if bundle check; then
    start_server
else
    bundle install && start_server
fi
