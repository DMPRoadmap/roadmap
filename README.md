# DMPTool

The DMPTool is a free, open-source, online application that helps researchers create data management plans. These plans, or DMPs, are now required by many funding agencies as part of the grant proposal submission process. The DMPTool provides a click-through wizard for creating a DMP that complies with funder requirements. It also has direct links to funder websites, help text for answering questions, and resources for best practices surrounding data management.

The DMPTool is based on the [DMPRoadmap](https://github.com/DMPRoadmap/roadmap) open source project. DMPRoadmap is being collaboratively developed by members of the University of California Curation Center (UC3), the Digital Curation Centre (DCC) and contributions from the community.

## Support

Issues should be reported here on [Github Issues](https://github.com/CDLUC3/dmptool/issues)
Please be advised though that we can only provide limited support for your local installations. Issues will be triaged by our team and if applicable will be moved/opened in the DMPRoadmap repository.

## Translations

See the [Translations Guide](https://github.com/DMPRoadmap/roadmap/wiki/Translations)

## Current Release
[v1.1.3](https://github.com/DMPRoadmap/roadmap/releases/tag/v1.1.3)

[![Build Status](https://travis-ci.org/DMPRoadmap/roadmap.svg)](https://travis-ci.org/DMPRoadmap/roadmap)


## Installation

If you would like to install and run this application, we encourage you to start with a basic [installation of DMPRoadmap](https://github.com/DMPRoadmap/roadmap/wiki/Installation). Follow the instructions and determine if the functionality it provides meets your requirements.

If the basic DMPRoadmap system does not provide the functionality you require please review the list of customizations that we have made below. If our additional changes do not meet your needs, you are encouraged to fork the DMPRoadmap codebase and customize it to your needs. If you do customize it please contact the DMPRoadmap team to let the community know about the additional functionality you plan to offer. It may be useful to the larger community.

If DMPTool meets your organization's needs, you should install it following the DMPRoadmap installation instructions and then perform the folowing tasks:
- **Homepage images:** While you are free to use the generic images provided along with this repository, it is advisable to replace them with ones more relevant to your user base. The system randomly serves up one of five images that are located in `lib/assets/images/homepage/`. Note that the `lib/stylesheets/dmptool/pages/home.scss` file references these images by name so you the ones you use should match the names in the scss file or you should update the scss file to use your image names.
- **Rotating news on the homepage:** Update the `config.rss` value in `config/application.rb` with the address of your blog's RSS feed.
- **Styles:** The system loads the base DMPRoadmap stylesheet first then the DMPTool stylesheet. We recommend that you add your own additional stylesheet if your changes are minor or update `lib/assets/stylesheets/dmptool.scss` and in `lib/assets/stylesheets/dmptool/*.scss` directly if the changes you nedd to make are extensive. Do not make changes to the other stylesheets in `lib/assets/stylesheets` as they are managed as part of the DMPRoadmap project.
- **Static Content:** Update/Replace the files in `app/views/static_pages/dmptool` so that they are appropriate for your installation. 
- **Shibboleth:** Setting up your own Shibboleth service provider (SP) is beyond the scope of this application. If you have an SP available and want to use it, make sure that you enable the shibboleth settings in `config/application.rb` and then add your Shib config to `config/initializers/devise.rb`. Once you are properly setup you will need to add an entity_id for each org so that the user is properly redirected to their IdP. The full list of IdP's can be found in your Shib SP's list of registered IdPs. We recommend adding the entity ids through the UI (admin -> organizations page). To verify that an org is properly configured you should logout of the UI and then click through to the 'sign via your institution' modal and check the contents of the dropdown. If the organization does not appear then its entity_id is not in the DB. If yoou select it and click the submit button you should be driven out to that org's IdP login page.

## Variations between DMPRoadmap and DMPTool

The following is a list of customizations that we have made to the base DMPRoadmap codebase:
- **Homepage:** A complete redesign of the homepage including homepage images found in `lib/assets/images/homepage`
- **Navigation:** A complete redesign of the header and footer navigation. All of the custom menus have been placed in `views/layouts/dmptool/`.
- **Static Content:** A complete rewrite of all the base static pages can be found in `app/views/static_pages/dmptool`
- **Sigin in/Create account:** The sign in and create account workflows has been overhauled to place more emphasis on logging in via institutional credentials (Shibboleth) and removing the need for new users to specify an organization when creating an account via email/password (they are auto-assigned to the Org with `orgs.is_other = true`. All of the DMPTool code for these items have been separated into its own `views/shared/dmptool/` subdirectory. The corresponding JS file can be found at `lib/assets/javascripts/dmptool/`.
- **Public participating institutions page:** A new Participating Institutions page has been added and is accessible to the public. 
- **Styling:** We have added a `lib/assets/stylesheets/dmptool.scss` file that gets loaded after the base DMPRoadmap stylesheets and loads in all of the separate SCSS files in `lib/assets/stylesheets/dmptool`
- **Create buttons:** All of the create buttons (e.g. Create Plan, Create Template) have been moved so that they appear on the upper right of their associated tables.
- **Accordion plus/minus (+/-) icons:** The plus/minus icons on the accordions have been moved so that they appear on the left.
- **Project details page:** The id field and contact phone numbers have been removed.
- **External links:** All external links (except ORCID) open in a new tab/window 
- **Asset fingerprinting:** A new configuration option has been added to allow you to specify whether or not you want the webpack managed assets to be fingerprinted. These options are set in the `config/environments/` files.
- **Max number of organization links:** Added a new constant for the max number of organization links that can appear in the header
- **Text/Labels:** Various text and labels have been updated.
- **Set min size for table columns with dates:** Added a 'last-edited' class to all table columns that contain a date to prevent their contents from wrapping.

## Troubleshooting

See the [Troubleshooting Guide](https://github.com/DMPRoadmap/roadmap/wiki/Troubleshooting) on the Wiki

## Contributing

See the [Contributing Guide](https://github.com/DMPRoadmap/roadmap/wiki/Get-involved)

## License
The DMPTool project uses the <a href="./LICENSE.md">MIT License</a>.
