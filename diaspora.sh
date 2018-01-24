#!/bin/bash

# Install diaspora servers

MASTER_PORT=3000
DEVELOP_PORT=3001

for instance in master develop; do
  git clone --depth 1 \
    https://github.com/diaspora/diaspora.git \
    -b $instance diaspora_$instance

  port=$MASTER_PORT
  if [[ "$instance" == "develop"  ]]; then
    port=$DEVELOP_PORT
  fi

  cp diaspora_$instance/config/diaspora.yml.example \
    diaspora_$instance/config/diaspora.yml
  sed -i "s/#url: \".*\"/url: \"http:\/\/localhost:$port\/\"/" \
    diaspora_$instance/config/diaspora.yml
  sed -i "s/#listen: 'unix:tmp\/diaspora.sock'/listen: 'tmp\/diaspora_$instance.sock'/" \
    diaspora_$instance/config/diaspora.yml

  cp diaspora_$instance/config/database.yml.example \
    diaspora_$instance/config/database.yml
  sed -i "s/database: diaspora_development/database: $instance/g" \
    diaspora_$instance/config/database.yml

  cd diaspora_$instance
  bundle install --with postgresql
  bundle exec rake db:create db:migrate
  PORT=$port ./script/server &
  cd -
done

# Wait till they finished loading
for port in $MASTER_PORT $DEVELOP_PORT; do
  while [[ "$(curl localhost:$port > /dev/null 2>&1; echo $?)" -ne "0" ]]; do
    echo "Waiting for localhost:$port"
    sleep 2
  done
done
