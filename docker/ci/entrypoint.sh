#!/bin/bash
set -e

export PGBIN="$(pg_config --bindir)"

su - postgres -c "$PGBIN/initdb -E UTF8 -D /tmp/nulldb"
su - postgres -c "$PGBIN/pg_ctl -D /tmp/nulldb -l /dev/null -w start"
echo "create database app; create user app with superuser encrypted password 'p4ssw0rd'; grant all privileges on database app to app;" | su - postgres -c psql

mkdir -p /home/$USER/openproject/tmp
mkdir -p /usr/local/bundle
mkdir -p /home/$USER/openproject/frontend/node_modules
mkdir -p /home/$USER/openproject/public/assets

chown $USER:$USER /usr/local/bundle
chown $USER:$USER /home/$USER/openproject/tmp
chown $USER:$USER /home/$USER/openproject/frontend/node_modules
chown $USER:$USER /home/$USER/openproject/public/assets


if [ "$1" == "setup" ]; then
	echo "Preparing environment for running tests..."
	shift
	time bundle install -j8
	time bash ./script/ci/cache_prepare.sh
	exec "$@"
else
	echo "Running arbitrary command without test setup..."
	exec "$@"
fi
