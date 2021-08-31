#!/bin/bash

set -eu

true "${HASH_SALT:?HASH_SALT is unset. Error.}"
true "${POSTGRES_USER:?POSTGRES_USER is unset. Error.}"
true "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD is unset. Error.}"
true "${POSTGRES_HOST:?POSTGRES_HOST is unset. Error.}"
true "${POSTGRES_DB:?POSTGRES_DB is unset. Error.}"


# Configure SMTP
sed -i "s/\$SMTP_HOST/$SMTP_HOST/g" /etc/msmtp/msmtp.conf
sed -i "s/\$SMTP_PORT/$SMTP_PORT/g" /etc/msmtp/msmtp.conf
sed -i "s/\$SMTP_AUTH/$SMTP_AUTH/g" /etc/msmtp/msmtp.conf
sed -i "s/\$SMTP_TLS/$SMTP_TLS/g" /etc/msmtp/msmtp.conf
sed -i "s/\$SMTP_USER/$SMTP_USER/g" /etc/msmtp/msmtp.conf
sed -i "s/\$SMTP_PASSWORD/$SMTP_PASSWORD/g" /etc/msmtp/msmtp.conf

chown www-data: /etc/msmtp/msmtp.conf && chmod 600 /etc/msmtp/msmtp.conf

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

if drush core-status --field=bootstrap | grep -q Successful ; then
  # Run database update and clear cache if we are bootstrapped
  drush updb -y
  drush cr
fi

exec "$@"
