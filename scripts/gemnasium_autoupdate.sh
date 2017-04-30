#!/bin/bash

if [[ $CIRCLE_BRANCH =~ "gemnasium-auto-update" ]]; then 
  echo "skipping build"; 
else
  echo "running autoupdate on " $GEMNASIUM_PROJECT_SLUG
  gemnasium au r;
fi