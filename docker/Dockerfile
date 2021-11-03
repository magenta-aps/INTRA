FROM drupal:9-php7.4-apache

ENV CROPPERJS_VERSION 1.5.12
ENV CROPPERJS_SHA1SUM d3ee5188bfbb14f96cb1ee684d836c5eb4da5c34
ENV CHOSEN_VERSION 1.8.7
ENV CHOSEN_SHA1SUM 45c7be97d98887d50948e96d7f0cd57b716c443b

# Install PHP extensions - using this github.com/mlocati/docker-php-extension-installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Installing GIT, APCu, Uploadprogress and Memcached extensions for php 7
# hadolint ignore=DL3008,DL4006
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
    && install --mode=600 --owner=www-data --group=www-data -D /dev/null /etc/msmtp/msmtp.conf \
    # Fetch CropperJS and Chosen third party library dependencies
    && curl -fsSL https://github.com/fengyuanchen/cropperjs/archive/refs/tags/v${CROPPERJS_VERSION}.zip -o ./cropper.zip \
    && curl -fsSL https://github.com/harvesthq/chosen/archive/refs/tags/v${CHOSEN_VERSION}.zip -o ./chosen.zip \
    && echo "${CROPPERJS_SHA1SUM} cropper.zip" | sha1sum -c - \
    && echo "${CHOSEN_SHA1SUM} chosen.zip" | sha1sum -c - \
    # Decompress and move thrd party libraries
    && unzip ./cropper.zip \
    && unzip ./chosen.zip \
    && rm ./cropper.zip ./chosen.zip \
    && mkdir /opt/drupal/web/libraries \
    && mv ./cropperjs-${CROPPERJS_VERSION}/ /opt/drupal/web/libraries/cropper/ \
    && mv ./chosen-${CHOSEN_VERSION}/ /opt/drupal/web/libraries/chosen/

# Install composer packages and set permissions on/in Drupal folder
WORKDIR /opt/drupal/
COPY --chown=www-data:www-data ./composer.* ./
RUN COMPOSER_MEMORY_LIMIT=-1 \
    COMPOSER_NO_INTERACTION=1 \
    composer install --optimize-autoloader \
    && composer clear-cache \
    && install --owner=www-data --group=www-data -d /opt/drupal/config/sync \
    && install --owner=www-data --group=www-data -d /opt/drupal/web/public-files/ \
    && chown -R www-data:www-data /opt/drupal/web/

# Copy configuration files
COPY ./docker/custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini
COPY --chown=www-data:www-data ./docker/httpd.conf /etc/apache2/sites-available/000-default.conf
COPY --chown=www-data:www-data ./docker/entrypoint.sh /opt/docker/entrypoint.sh
COPY --chown=www-data:www-data ./site-settings.php /opt/drupal/web/sites/default/settings.php
COPY --chown=www-data:www-data ./docker/site-install.sh /opt/docker/site-install.sh

COPY --chown=www-data:www-data ./tests ./tests

COPY --chown=www-data:www-data ./custom-profiles /opt/drupal/web/profiles/custom
COPY --chown=www-data:www-data ./custom-modules /opt/drupal/web/modules/custom
COPY --chown=www-data:www-data ./custom-themes /opt/drupal/web/themes/custom

VOLUME /etc/msmtp/
VOLUME /opt/drupal/config/sync/
# For static js, css et. al. files.
VOLUME /opt/drupal/web/sites/default/
# For user uploaded files.
VOLUME /opt/drupal/web/public-files/

# Listen on Apache network port
EXPOSE 80

# Execute entrypoint.sh
ENTRYPOINT ["/opt/docker/entrypoint.sh"]

# Run Drupal9 install with apache
CMD ["apache2-foreground"]
