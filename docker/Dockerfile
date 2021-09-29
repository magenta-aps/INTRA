FROM drupal:9-php7.4-apache

# Install PHP extensions - using this github.com/mlocati/docker-php-extension-installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Installing GIT, APCu, Uploadprogress and Memcached extensions for php 7
# hadolint ignore=DL3008
RUN set -eux \
    && chmod uga+x /usr/local/bin/install-php-extensions \
    && sync \
    && rm /etc/apt/preferences.d/no-debian-php \
    && apt-get update \
    && apt-get install -y --no-install-recommends git unzip libz-dev libmemcached-dev msmtp postgresql \
    && pecl install apcu uploadprogress memcached \
    && docker-php-ext-enable apcu uploadprogress memcached \
    && apt-get clean && rm -rf "/var/lib/apt/lists/*" "/tmp/*" "/var/tmp/*" "/usr/share/man/??" "/usr/share/man/??_*" \
    # like `touch`, but with mode, owner, group and creation of parent dirs.
    && install --mode=600 --owner=www-data --group=www-data -D /dev/null /etc/msmtp/msmtp.conf

# Install composer packages and set permissions on/in Drupal folder
WORKDIR /opt/drupal/
COPY --chown=www-data:www-data ./composer.* ./
RUN COMPOSER_MEMORY_LIMIT=-1 \
    COMPOSER_NO_INTERACTION=1 \
    composer install --optimize-autoloader \
    && composer clear-cache \
    && chown -R www-data:www-data /opt/drupal/web/

# Copy configuration files
COPY ./docker/custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini
COPY --chown=www-data:www-data ./docker/httpd.conf /etc/apache2/sites-available/000-default.conf
COPY --chown=www-data:www-data ./docker/entrypoint.sh /opt/docker/entrypoint.sh
COPY --chown=www-data:www-data ./site-settings.php /opt/drupal/web/sites/default/settings.php
COPY --chown=www-data:www-data ./docker/site-install.sh /opt/docker/site-install.sh

COPY --chown=www-data:www-data ./tests ./tests

COPY --chown=www-data:www-data ./custom-profiles/custom/magentaintra_profile /opt/drupal/web/profiles/custom/magentaintra_profile
COPY --chown=www-data:www-data ./custom-module/custom/magentaintra /opt/drupal/web/modules/custom/magentaintra

VOLUME /etc/msmtp/
VOLUME /opt/drupal/config/sync/
VOLUME /opt/drupal/web/sites/default/

# Listen on Apache network port
EXPOSE 80

# Execute entrypoint.sh
ENTRYPOINT ["/opt/docker/entrypoint.sh"]

# Run Drupal9 install with apache
CMD ["apache2-foreground"]
