## DMP Roadmap

DMP Roadmap is a Data Management Planning tool. Management and development of DMP Roadmap is jointly provided by the Digital Curation Centre (DCC), http://www.dcc.ac.uk/, and the University of California Curation Center (UC3), http://www.cdlib.org/services/uc3/

The tool has four main functions:  

1. To help create and maintain different versions of Data Management Plans;  
2. To provide useful guidance on data management issues and how to meet research funders' requirements;  
3. To export attractive and useful plans in a variety of formats;  
4. To allow collaborative work when creating Data Management Plans.  

#### Current Release
v.0.1.0
[![Build Status](https://travis-ci.org/DMPRoadmap/roadmap.svg)](https://travis-ci.org/DMPRoadmap/roadmap)

#### Summary

#### Pre-requisites
Roadmap is a Ruby on Rails application and you will need to have: 
1. Ruby >= 2.0.0p247
2. Rails >= 4.0
3. MySql >= 5.0

Further details on how to install Ruby on Rails applications are available from the Ruby on Rails site: http://rubyonrails.org

Further details on how to install MySQL and create your first user and database. Be sure to follow the instructions for your particular environment. 
* Install: http://dev.mysql.com/downloads/mysql/
* Create a user: http://dev.mysql.com/doc/refman/5.7/en/create-user.html
* Create the database: http://dev.mysql.com/doc/refman/5.7/en/creating-database.html

You may also find the following resources handy:

* The Getting Started Guide: http://guides.rubyonrails.org/getting_started.html
* Ruby on Rails Tutorial Book: http://www.railstutorial.org/

#### Installation
* Create your mysql db. Select UTF-8 Unicode (utf8mb4) encoding.
* Fork the repository and then clone it onto your server

>     > git clone https://github.com/[your organization]/roadmap.git

>     > cd roadmap

* Make copies of the yaml configuration files and update the values for your installation

>     > cp config/database_example.yml config/database.yml
>     > cp config/secrets_example.yml config/secrets.yml

* Make copies of the example gem initializer files and update the values for your installation

>     > cp config/initializers/devise.rb.example config/initializers/devise.rb
>     > cp config/initializers/recaptcha.rb.example config/initializers/recaptcha.rb
>     > cp config/initializers/wicked_pdf.rb.example config/initializers/wicked_pdf.rb

* Create an environment variable for your instance's secret (as defined in config/secrets.yml). You should use the following command to generate secrets for each of your environments, storing the production one in the environment variable:

>     > rake secret

* Run bundler and perform the DB migrations

>     > gem install bundler (if bundler is not yet installed)

>     > bundle install

>     > rake db:migrate

>     > rake db:seed    (Unless you are migrating data from an old DMPOnline system)

* Start the application

>     > rails server

* Verify that the site is running properly by going to http://localhost:3000
* Login as the default administrator: 'super_admin@example.com' - 'password1'

#### Migrating data from a running instance of DMPOnline_v4 into DMPRoadmap

TODO: Add instructions on exporting data from the old DB and migrating it into the Roadmap DB

#### Troubleshooting
##### Installation - OSX:

```
An error occurred while installing libv8 (3.11.8.17), and Bundler cannot continue.

Make sure that `gem install libv8 -v '3.11.8.17'` succeeds before bundling. 
```

If you are installing on a system that already has v8 installed then you may need to install the libv8 gem manually using your system's current v8 engine. If you're using homebrew to manage your packages you should run 'brew update' and 'brew upgrade' to make sure you have the latest packages

>     > gem uninstall -a libv8

>     > gem install libv8 -v '<<VERSION>>' -- --with-system-v8

>     > bundle install

##### Post Installation Issues

I installed the system and migrated my legacy DMPOnline data into the database but none of my users are able to login!

This happens when the 'pepper' key defined in config/initializers/devise.rb does not match the one on your old server. Simply update the pepper and restart the application.

___

I am getting an undefined method 'devise' on the app/modles/user.rb object when running tests or trying to start the service.

This happens when you have not created a copy of the devise.rb.example initializer file. To correct it copy the file and update its parameters accordingly:
>     > cp config/initializers/devise.rb.example config/initializers/devise.rb

#### Support
Issues should be reported here on [Github Issues](https://github.com/DMPRoadmap/roadmap/issues)
Please be advised though that we can only provide limited support for your local installations.

#### Become a contributor
Fork this repository and make your modifications in a new branch. Then create a pull request to our 'development' branch. We will reject any pull request made against the 'master' branch. Once your pull request has been submitted the team will review your request and accept it if appropriate.

Join the developer email listserv at www.jiscmail.ac.uk/DMPONLINE-DEV

#### License
The DMP Roadmap project uses the <a href="./LICENSE.md">MIT License</a>.
