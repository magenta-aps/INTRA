# Project description
This project includes Drupal 9, Drush 10, Composer install of Drupal Recommended Project and can be used to develop, stage or put into production any Drupal 9 project.

Also included are drush/config-extra and other utilities for CI/CD in terms of a Drupal project - site updates, database schema updates, database backups, push of databases via git, backup of files, replication of production environments and much more.

This is a terminal built environment based on the minimal install profile and the `./drush site:install minimal` command.

The thought behind this approach is to prepare the environment and tools needed to always be running an updated system with a modern proactive approach. The main goal is to have a fully automated production ready installation. Thus this project includes no modules, dependencies or themes not needed for the project beforehand, making it more manageable and minimal in terms of maintenance.

## Development


### Run with Docker

For development purposes this project can be started with:

   ```sh
   $ docker-compose up -d
   ```

Drupal 9 will be available via [localhost:9998](http://localhost:9998/)

phpMyAdmin will for development purposes be available via [localhost:9999](http://localhost:9999/)

#### Basic site configuration
Rename your project or set your frontpage url:

- [go to your basic settings page via GUI](http://localhost:9998/admin/config/system/site-information)
- fill in the field "Default front page" with `/node`
- [visit the frontpage](http://localhost:9998/)

#### Fix file and cache permissions:

   ```sh
   $ chmod 777 -R web/sites/default/files
   ```

#### Configure trusted hosts in web/sites/default/settings.php
   For more information on how to write this, see the section for [Trusted Host settings](https://www.drupal.org/docs/installing-drupal/trusted-host-settings)
   in the official Drupal installation guide.
   ```php
   // web/sites/default/settings.php

   $settings['trusted_host_patterns'] = [''];
   ```


### Using Composer

#### Composer dependencies

To install modules or other dependencies strictly use Composer. Installed dependencies are locked to specific versions using the `composer.lock` file. `composer install` will install every package specified in `composer.json` with respect to the pinned versions in `composer.lock`.

#### Adding dependencies

Use `composer require` to add and install new packages. Alternatively add the requirement to `composer.json` and run `composer install`.
   
   ```sh
    $ docker-compose exec -T drupal composer require "vendor/package:2.*"
   ```

#### Updating dependencies

When a version update is needed, use `composer update vendor/package`. 
    
   ```sh
   $ docker-compose exec -T drupal composer update vendor/package
   ```

On first run, the `composer.lock` file was generated using `composer update` without further parameters.

#### Updating translations for developers

We store our full translation in the repository in the '/opt/drupal/translations' directory. All translations are deployed in order to have full control.
In Drupal 9 we use the Gettext po file format for translations. We do not overwrite translations made on production systems using GUI.
We use Drupal core and Drush as much as possible:`
'drush locale:import` is available since Drush 9.5.0
`drush locale:export` is available since Drush 10.3.0

There are three streams that make up the Drupal 9 translation interface
1. Community translations for core and contributed modules
2. Interface translation for custom modules and theme
3. Custom interface translations that override the other translations

##### Community translations

The Locale module, shipped with core, can download community translations from the translation server at https://localize.drupal.org/. 
Since we want to have full control over which translations gets used and when, we download translations from this server with Drush into the development environment. 
From there the translation files get stored in the Git repo. During deployment the translations on staging or production gets updated using the translation files stored in the repository.

##### Translations for custom code

Custom modules and themes can contain new translatable strings. 
The developer either exports the translatable strings with the Potx module, or manually creates a gettext .po file with the strings and their translation. 
Register the translation file by adding the lines below to the module.info.yml file. Note that the po file name does not contain a module version number (e.g. example.da.po).   
   ```yaml
   // modules/contrib/%project.info.yml

    interface translation project: {module name}
    interface translation server pattern: modules/custom/%project/translations/%project.%language.po
   ```
The gettext .po file that contains the translations of the ‘example’ module is placed in the path assigned above. For example: `modules/custom/example/translations/example.da.po.`

##### Custom translations

Custom translations override the other translations. Custom Translations are flagged in the database as custom. Custom translations are not overridden by the default translation import. 

In a project, custom translations are particularly useful to override community translations, for example to change message texts.

##### Our configuration

For full control we only import local translations and follow these guidelines during deployment:
1. Never check for updates.
2. Only use local translation source.
3. Only overwrite imported translations.

NOTE: We update our translation with changes automatically on each init-container run.

###### Development environment

The development environment can be configured differently from staging and production using an environment variable. 
It uses the remote and local translation source. We can set the source in `dev-environment/intra.env` during development:

   ```
    TRANSLATION_SOURCE=remote_and_local
   ```
Restart your docker container and new community and third party module translations will be downloaded to the `/opt/drupal/translations` folder:
   ```sh
   $ docker-compose up
   ```
###### Update project translations

For project specific translation we use `translations/project_specific-custom.da.po` file which will update the development instance on container rebuild or restart.
After an update to translations we must push the changes to our remote repository.
During development we import interface translations for core, contributed modules and custom modules. These updated .po files should be committed to the repository to update the translations in production.

The translations directory is placed outside the webroot and included in the repository. 
Our interface translations directory is set to: `/opt/drupal/translations` (see `http://localhost:9998/admin/config/media/file-system`)

#### Running test with Codeception

Run Acceptance test:
      
   ```sh
   $ docker-compose exec drupal php vendor/bin/codecept bootstrap 
   ```

   ```sh
   $ docker-compose exec drupal php vendor/bin/codecept run acceptance --steps
   ```

### Using Drush

Run Drush commands using - this command provides a full list of useful Drush commands:

   ```sh
   $ docker-compose exec -T drupal ./drush
   ```
Full list of commands in [Drush 9](https://drushcommands.com/drush-9x/). A list such as this one is not available yet fir Drush 10 but should suffice.

### Elasticsearch integration

MagentaINTRA uses Elasticsearch as a service for indexation and advanced search.

### Development and mantainance
This project was developed by [Magenta Open Source IT](https://magenta.dk)
