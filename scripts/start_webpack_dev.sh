#!/bin/sh

echo "starting webpack dev" && export NODE_OPTIONS="--max_old_space_size=4096" && yarn --skip-integrity-check && rm -rf /public/packs && bin/webpack-dev-server
