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

Developed by [Magenta Open Source IT](https://magenta.dk)
Maintained by [Mads Nørgaard](https://github.com/madsnorgaard)


### Using ELK-stack

The ELK-stack consists of 3 components; logstash, elasticsearch and Kinana.
The 3 components is all included in this image.

Logstash listens for events in tha database and in a file. 
The file is a simple dummy-file, just to demonstrate, it can be mapped to logfiles in the application.
From the database logstash fetches information about logins from the users of the application

Logstash forwards the information from the application to elasticsearch, where the information is indexed.

In Kibana the dashbords og the indexed information from elasticsearch is created.
There is stored an exampledashboard in the folder .kibana/setup.

The exampledashboard can be loaded into the ELK-stack from the following link: 

http://localhost:5601/app/management/kibana/objects
