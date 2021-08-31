#!/bin/bash

set -eu

if ! drush core-status --field=bootstrap | grep -q Successful ; then
    echo "Drupal is not bootstrapped - starting site-install"
    echo "Uninstalling Update Manager module"
    drush site-install \
          magentaintra_profile \
          install_configure_form.enable_update_status_module=NULL \
          -y \
          --verbose \
          --site-name="$SITE_NAME" \
          --site-mail="$SITE_MAIL" \
          --account-mail="$ACCOUNT_MAIL" \
          --account-name="$ACCOUNT_NAME" \
          --account-pass="$ACCOUNT_PASS"

else
    echo "Drupal already bootstrapped - skipping install"
fi
