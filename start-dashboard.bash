#!/bin/bash

set -o errexit

URL=http://localhost:3030/sampletv

##
# Start the dashboard, if URL is not already available
##
if [ "$(curl --output /dev/null --silent -w '%{http_code}' --fail $URL)" != "200" ]; then
  dashing start >& /dev/null &
fi

##
# Wait until the dashboard is up and running
##
until [ "$(curl --output /dev/null --silent -w '%{http_code}' --fail $URL)" == "200" ]; do
  echo "Waiting for ${URL}..."
  sleep 2
done

echo "Starting web browser..."
midori -e Fullscreen --app "$URL"
