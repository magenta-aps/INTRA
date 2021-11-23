#!/bin/bash

set -eu

true "${HASH_SALT:?HASH_SALT is unset. Error.}"
true "${POSTGRES_USER:?POSTGRES_USER is unset. Error.}"
true "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is unset. Error.}"
true "${POSTGRES_HOST:?POSTGRES_HOST is unset. Error.}"
true "${POSTGRES_DB:?POSTGRES_DB is unset. Error.}"


# Configure SMTP
cat << EOF > /etc/msmtp/msmtp.conf
host ${SMTP_HOST:?SMTP_HOST is unset. Error.}
port ${SMTP_PORT:-587}
auth ${SMTP_AUTH:-on}
tls ${SMTP_TLS:-on}
user ${SMTP_USER:-}
password ${SMTP_PASSWORD:-}
EOF

NUM=150
until false
do
  drush sql:query "SELECT 1" &> /dev/null && break
  ((NUM--))
  echo Waiting for database connection. Trying $NUM more times.
  if [ $NUM -le 0 ]; then
     exit 1
  fi
  sleep 0.2
done
echo Connected to database.

# Check if Drupal is installed (bootstrapped) and run commands if true
if drush core-status --field=bootstrap | grep -q Successful ; then
echo "Run database update to trigger changes to schema for updated modules and rebuild cache"
  drush updatedb -y
  drush cache-rebuild
fi

exec "$@"
