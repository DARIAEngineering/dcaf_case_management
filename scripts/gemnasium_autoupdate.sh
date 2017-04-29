#!/bin/bash

if [[ $CIRCLE_BRANCH =~ "gemnasium-auto-update" ]]; then 
  echo "skipping build"; 
else
  echo "running autoupdate"
  gemnasium au r;
fi