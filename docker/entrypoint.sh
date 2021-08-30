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

if ! drush core-status --field=bootstrap | grep -q Successful ; then
    echo "Drupal is not bootstrapped - starting site-install"
    echo "Uninstalling Update Manager module"
    drush site-install \
          magentaintra_profile \
          install_configure_form.enable_update_status_module=NULL \
          -y \
          --locale="da" \
          --verbose \
          --site-name="$SITE_NAME" \
          --site-mail="$SITE_MAIL" \
          --account-mail="$ACCOUNT_MAIL" \
          --account-name="$ACCOUNT_NAME" \
          --account-pass="$ACCOUNT_PASS"

else
    echo "Drupal already bootstrapped - skipping install"
fi

# Run database update and clear cache
drush updb -y
drush cr

exec "$@"
