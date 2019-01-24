# DMPTool

The DMPTool is a free, open-source, online application that helps researchers create data management plans. These plans, or DMPs, are now required by many funding agencies as part of the grant proposal submission process. The DMPTool provides a click-through wizard for creating a DMP that complies with funder requirements. It also has direct links to funder websites, help text for answering questions, and resources for best practices surrounding data management.

The DMPTool is based on the [DMPRoadmap](https://github.com/DMPRoadmap/roadmap) open source project. DMPRoadmap is being collaboratively developed by members of the University of California Curation Center (UC3), the Digital Curation Centre (DCC) and contributions from the community.

Click here for the latest [releases].(https://github.com/CDLUC3/dmptool/releases/)

[![Build Status](https://travis-ci.org/CDLUC3/dmptool.svg)](https://travis-ci.org/CDLUC3/dmptool)

## Support

Issues should be reported here on [Github Issues](https://github.com/CDLUC3/dmptool/issues)
Please be advised though that we can only provide limited support for your local installations. Issues will be triaged by our team and if applicable will be moved/opened in the DMPRoadmap repository.

## Translations

See the [Translations Guide](https://github.com/DMPRoadmap/roadmap/wiki/Translations)

#### Pre-requisites
Roadmap is a Ruby on Rails application and you will need to have:
* Ruby >= 2.4.4
* Rails >= 4.2
* MySQL >= 5.0 OR PostgreSQL

## Installation

If you would like to install and run this application, we encourage you to start with a basic [installation of DMPRoadmap](https://github.com/DMPRoadmap/roadmap/wiki/Installation). Follow the instructions and determine if the functionality it provides meets your requirements.

If the basic DMPRoadmap system does not provide the functionality you require please review the list of customizations that we have made below. If our additional changes do not meet your needs, you are encouraged to fork the DMPRoadmap codebase and customize it to your needs. If you do customize it please contact the DMPRoadmap team to let the community know about the additional functionality you plan to offer. It may be useful to the larger community.

If DMPTool meets your organization's needs, you should install it following the DMPRoadmap installation instructions and then perform the folowing tasks:

- **Homepage images:** While you are free to use the images provided along with this repository, it is advisable to replace them with ones more relevant to your user base. The system randomly serves up one of five images that are located in `app/assets/images/homepage/`. Each image has 3 sizes geared towards various device resolutions/format (e.g. smart phone). Follow the image sizes in the provided examples for your images. You must also retain the file names as the `app/assets/stylesheets/dmptool/blocks/_home_welcome.scss` references them by name
- **Rotating news on the homepage:** Update the `config.rss` value in `config/application.rb` with the address of your blog's RSS feed.
- **Styles:** The system loads the base DMPRoadmap stylesheet first then the DMPTool stylesheet. We recommend that you add your own additional stylesheet if your changes are extensive or update `app/assets/stylesheets/dmptool/**/*.scss` directly. Do not make changes to the other stylesheets as they are managed as part of the DMPRoadmap project.
- **Static Content:** Update the files in `app/views/branded/static_pages/` so that they are appropriate for your installation.
- **Shibboleth:** Setting up your own Shibboleth service provider (SP) is beyond the scope of this application. If you have an SP available and want to use it, make sure that you enable the shibboleth settings in `config/application.rb` and then add your organization's entity id (found in your Shib SP's list of registered IdPs) within the UI. Then log out and log back in via your institution's credentials to test that things are working properly. Note that the DMPTool only allows users to authenticate via Shibboleth if the organization is regsitered within the system (meaning that it appears in the application's `orgs` table)

## Variations between DMPRoadmap and DMPTool

The following is a list of customizations that we have made to the base DMPRoadmap codebase:

- **Homepage:** A complete redesign of the homepage
- **Navigation:** A complete redesign of the header and footer navigation. All of the custom menus have been placed in `app/views/branded/layouts/`.
- **Static Content:** Added a gem to allow the `app/views/branded/static_pages` to be managed via Markdown instead of HTML. Changed the content of existing pages and added new pages
- **Sigin in/Create account:** The sign in and create account workflows has been overhauled to place more emphasis on logging in via institutional credentials (Shibboleth). All of the DMPTool code for these items have been separated into its own `app/views/branded/shared/` subdirectory. The corresponding JS file can be found at `app/javascript/dmptool/`.
- **Public participating institutions page:** A new Participating Institutions page has been added and is accessible to the public.
- **Styling:** We have added `app/assets/stylesheets/dmptool/**/*.scss` files that gets loaded after the base DMPRoadmap stylesheets
- **Create buttons:** All of the create buttons (e.g. Create Plan, Create Template) have been moved so that they appear on the upper right of their associated tables.
- **Accordion plus/minus (+/-) icons:** The plus/minus icons on the accordions have been moved so that they appear on the left.
- **Project details page:** The id field and contact phone numbers have been removed.
- **Max number of organization links:** Added a new constant for the max number of organization links that can appear in the header
- **Text/Labels:** Various text and labels have been updated.

## Troubleshooting

See the [Troubleshooting Guide](https://github.com/DMPRoadmap/roadmap/wiki/Troubleshooting) on the Wiki

## Contributing

See the [Contributing Guide](https://github.com/DMPRoadmap/roadmap/wiki/Get-involved)

## License
The DMPTool project uses the <a href="./LICENSE.md">MIT License</a>.
