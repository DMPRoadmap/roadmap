## DMP Roadmap

DMP Roadmap is a Data Management Planning tool. Management and development of DMP Roadmap is jointly provided by the Digital Curation Centre (DCC), http://www.dcc.ac.uk/, and the University of California Curation Center (UC3), http://www.cdlib.org/services/uc3/

The tool has four main functions:

1. To help create and maintain different versions of Data Management Plans;
2. To provide useful guidance on data management issues and how to meet research funders' requirements;
3. To export attractive and useful plans in a variety of formats;
4. To allow collaborative work when creating Data Management Plans.

Click here for the latest [releases].(https://github.com/DMPRoadmap/roadmap/releases/)
[![Build Status](https://travis-ci.org/DMPRoadmap/roadmap.svg)](https://travis-ci.org/DMPRoadmap/roadmap)

#### Pre-requisites
Roadmap is a Ruby on Rails application and you will need to have:
* Ruby >= 2.4.4
* Rails >= 4.2
* MySQL >= 5.0 OR PostgreSQL

Further detail on how to install Ruby on Rails applications are available from the Ruby on Rails site: http://rubyonrails.org

Further details on how to install MySQL and create your first user and database. Be sure to follow the instructions for your particular environment.
* Install: http://dev.mysql.com/downloads/mysql/
* Create a user: http://dev.mysql.com/doc/refman/5.7/en/create-user.html
* Create the database: http://dev.mysql.com/doc/refman/5.7/en/creating-database.html

You may also find the following resources handy:

* The Getting Started Guide: http://guides.rubyonrails.org/getting_started.html
* Ruby on Rails Tutorial Book: http://www.railstutorial.org/

#### Installation
See the [Installation Guide](https://github.com/DMPRoadmap/roadmap/wiki/Installation) on the Wiki

#### Troubleshooting
See the [Troubleshooting Guide](https://github.com/DMPRoadmap/roadmap/wiki/Troubleshooting) on the Wiki

#### Support
Issues should be reported here on [Github Issues](https://github.com/DMPRoadmap/roadmap/issues)
Please be advised though that we can only provide limited support for your local installations.

#### Become a contributor
If you would like to contribute to the project. Please follow these steps to submit a contribution:
* Comment on the Github issue (or create one if one does not exist) and let us know that you're working on it.
* Fork the project (if you have not already) or rebase your fork so that it is up to date with the current repository's '_**development**_' branch
* Create a new branch in your fork. This will ensure that you are able to work at your own pace and continue to pull in any updates made to this project.
* Make your changes in the new branch
* When you have finished your work, make sure that your version of the '_**development**_' branch is still up to date with this project. Then merge your new branch into your '_**development**_' branch.
* Then create a new Pull Request (PR) to this project's '_**contributions**_' branch in GitHub
* The project team will then review your PR and communicate with you to convey any additional changes that would ensure that your work adheres to our guidelines.

See the [Contribution Guide](https://github.com/DMPRoadmap/roadmap/wiki/Contributing) on the Wiki for more details

#### License
The DMP Roadmap project uses the <a href="./LICENSE.md">MIT License</a>.

# Docker
This project comes with a docker setup to easily setup your own local development environment for jupiter in just a few steps.

## Step 1: Make sure you have docker and docker-compose installed:

1. [Install Docker](https://docs.docker.com/engine/installation/) (Requires version 1.13.0+)
2. [Install Docker Compose](https://docs.docker.com/compose/install/) (Requires version 1.10.0+)

### Still need more help? Check out the following

#### OSX / Windows
- If you are on Mac, check out [Docker for Mac](https://docs.docker.com/docker-for-mac/)
- If you are on Windows, check out [Docker for Windows](https://docs.docker.com/docker-for-windows/)

These will install `docker`, `docker-compose`, and `docker-machine` on your machine.

#### Linux

Use your distribution's package manager to install `docker` and `docker-compose`.

## Step 2: Get DMP Roadmap source code
Clone the Jupiter repository from github:
```shell
git clone git@github.com:ualbertalib/DMP_roadmap.git
cd DMP_roadmap
```

## Step 3: Start docker and docker compose

### For development environment
To start and setup your docker containers run:
```shell
docker-compose -f docker-compose.lightweight.yml up -d
```

Now everything should be up and running. If you need seed to setup your database, then run the following command:
```shell
bundle exec rake db:setup
```

Then start your rails server run:
```shell
bundle exec rails s
```
### For UAT environment
To start your docker containers run:
```shell
docker-compose -f docker-compose.yml up -d
```

Now everything should be up and running. The rails runs on port 3000. If you need to setup your database, then run the following command:
```shell
docker system exec -it dmproadmap_web_1 /bin/bash
```

At this point, you should be on your web docker. Now, you can run the following command to setup your database.
```shell
bundle exec rake db:reset
```

## Step 4: Open and view DMP Roadmap!
Now everything is ready, you can go and view DMPRoadmap! Just open your favorite browser and go to the following url:

  - Development environment: [localhost:3000](http://localhost:3000)
  - UAT environment: [uatsrv01.library.ualberta.ca:3000](http://uatsrv01.library.ualberta.ca:3000/)


