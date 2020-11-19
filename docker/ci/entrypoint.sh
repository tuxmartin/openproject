#!/bin/bash
set -e

export PGBIN="$(pg_config --bindir)"

su - postgres -c "$PGBIN/initdb -D /tmp/nulldb"
su - postgres -c "$PGBIN/pg_ctl -D /tmp/nulldb -l /dev/null -w start"
echo "create database app; create user app with encrypted password 'p4ssw0rd'; grant all privileges on database app to app;" | su - postgres -c psql

mkdir -p /home/$USER/openproject/tmp
mkdir -p /usr/local/bundle
chown $USER:$USER /usr/local/bundle
chown $USER:$USER /home/$USER/openproject/tmp

if [ "$1" == "" ]; then
	exec bash
else
	su - dev -c "time bundle install -j8"
	su - dev -c "time bash ./script/ci/cache_prepare.sh"
	su - dev -c "time bash script/ci/runner.sh units 5 1"
fi
