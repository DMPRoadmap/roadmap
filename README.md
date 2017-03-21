## DMP Roadmap

DMP Roadmap is a Data Management Planning tool. Management and development of DMP Roadmap is jointly provided by the Digital Curation Centre (DCC), http://www.dcc.ac.uk/, and the University of California Curation Center (UC3), http://www.cdlib.org/services/uc3/

The tool has four main functions:  

1. To help create and maintain different versions of Data Management Plans;  
2. To provide useful guidance on data management issues and how to meet research funders' requirements;  
3. To export attractive and useful plans in a variety of formats;  
4. To allow collaborative work when creating Data Management Plans.  

#### Current Release
Official release coming soon!
[![Build Status](https://travis-ci.org/DMPRoadmap/roadmap.svg)](https://travis-ci.org/DMPRoadmap/roadmap)

#### Summary

#### Pre-requisites
Roadmap is a Ruby on Rails application and you will need to have: 
* Ruby >= 2.2.2
* Rails >= 4.2
* MySql >= 5.0 OR PostgreSql

#### Migrating data from a running instance of DMPOnline_v4 or DMPTool
Migration instructions will be coming soon

Further details on how to install MySQL and create your first user and database. Be sure to follow the instructions for your particular environment. 
* Install: http://dev.mysql.com/downloads/mysql/
* Create a user: http://dev.mysql.com/doc/refman/5.7/en/create-user.html
* Create the database: http://dev.mysql.com/doc/refman/5.7/en/creating-database.html

You may also find the following resources handy:

* The Getting Started Guide: http://guides.rubyonrails.org/getting_started.html
* Ruby on Rails Tutorial Book: http://www.railstutorial.org/

#### Installation
* Create your database. Select UTF-8 Unicode (utf8) encoding.
* Clone this repository (or Fork the repository first if you plan on contributing)

>     > git clone https://github.com/[your organization]/roadmap.git

>     > cd roadmap

* Make copies of the yaml configuration files and update the values for your installation

>     > cp config/database_example.yml config/database.yml
>     > cp config/secrets_example.yml config/secrets.yml

* Make copies of the example gem initializer files and update the values for your installation

>     > cp config/initializers/devise.rb.example config/initializers/devise.rb
>     > cp config/initializers/recaptcha.rb.example config/initializers/recaptcha.rb
>     > cp config/initializers/wicked_pdf.rb.example config/initializers/wicked_pdf.rb
>     > cp config/locales/*.static.yml.example config/locales/*.static.yml

* Create an environment variable for your instance's secret (as defined in config/secrets.yml). You should use the following command to generate secrets for each of your environments, storing the production one in the environment variable:

>     > rake secret

* Run bundler and perform the DB migrations

>     > gem install bundler (if bundler is not yet installed)

>     > bundle install

>     > rake db:schema:load

>     > rake db:seed    (Unless you are migrating data from an old DMPOnline system)

* Start the application

>     > rails server

* Verify that the site is running properly by going to http://localhost:3000
* Login as the default administrator: 'super_admin@example.com' - 'password123'

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
