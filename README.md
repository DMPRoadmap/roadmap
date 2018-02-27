## DMPTool

The DMPTool is a free, open-source, online application that helps researchers create data management plans. These plans, or DMPs, are now required by many funding agencies as part of the grant proposal submission process. The DMPTool provides a click-through wizard for creating a DMP that complies with funder requirements. It also has direct links to funder websites, help text for answering questions, and resources for best practices surrounding data management.

The DMPTool is based on the [DMPRoadmap](https://github.com/DMPRoadmap/roadmap) open source project. DMPRoadmap is being collaboratively developed by members of the University of California Curation Center (UC3), the Digital Curation Centre (DCC) and contributions from the community.

### Support
Issues should be reported here on [Github Issues](https://github.com/CDLUC3/dmptool/issues)
Please be advised though that we can only provide limited support for your local installations. Issues will be triaged by our team and if applicable will be moved/opened in the DMPRoadmap repository if applicable.

### Installation

If you would like to install and run this application, we encourage you to start with a basic [installation of DMPRoadmap](https://github.com/DMPRoadmap/roadmap/wiki/Installation). Follow the instructions and determine if the functionality it provides meets your requirements.

If you have already reviewed the basic functionality of DMPRoadmap and still want to install the DMPTool codebase please follow the core set of DMPRoadmap installation instructions and then perform the following tasks for the DMPTool implementation:
- *Homepage images:* While you are free to use the images provided along with this repository, it is advisable to replace them with ones more relevant to your user base. The system randomly serves up one of five images that are located in `lib/assets/images/homepage/`. Each image has 3 sizes geared towards various device resolutions/format (e.g. smart phone). Follow the image sizes in the provided examples for your images. You must also retain the file names as the `lib/assets/stylesheets/dmptool.scss` references them by name
- *Rotating news on the homepage:* Update the `config.rss` value in `config/application.rb` with the address of your blog's RSS feed.
- *Styles:* The system loads the base DMPRoadmap stylesheet first then the DMPTool stylesheet. We recommend that you add your own additional stylesheet if your changes are extensive or update `lib/assets/stylesheets/dmptool.scss` directly. Do not make changes to the other stylesheets as they are managed as part of the DMPRoadmap project.
- *Static Content:* Update the files in `app/views/static_pages/` so that they are appropriate for your installation. 
- *Shibboleth:* Setting up your own Shibboleth service provider (SP) is beyond the scope of this application. If you have an SP available and want to use it, make sure that you enable the shibboleth settings in `config/application.rb` and then add your organization's entity id (found in your Shib SP's list of registered IdPs) within the UI. Then log out and log back in via your institution's credentials to test that things are working properly. Note that the DMPTool only allows users to authenticate via Shibboleth if the organization is regsitered within the system (meaning that it appears in the application's `orgs` table)

### Differences between DMPRoadmap and DMPTool

- *Basics:* The Homepage, header and footer menus and stylesheet has been customized to fit the DMPTool's needs
- *Content:* The about, help and other static pages have been updated. We also switched these files over so that they can be edited in Markdown instead of HTML
- *Sigin in/Create account:* The sign in and create account workflows differ. All of the DMPTool code for these items have been separated into their own `dmptool/` subdirectories
- *Participating institutions:* We offer a list of participating institutions page
- *Create buttons:* All of the create buttons (e.g. Create Plan, Create Template) have been moved so that they appear above the tables
- *Plus/minus icons:* The plus/minus icons on the accordions have been moved so that they appear on the left
- *Project details page:* The id field and contact phone numbers have been removed.
- *External links:* All external links (except ORCID) open in a new tab/window 

### Troubleshooting
See the [Troubleshooting Guide](https://github.com/DMPRoadmap/roadmap/wiki/Troubleshooting) on the Wiki

### Contributing
See the [Contributing Guide](https://github.com/DMPRoadmap/roadmap/wiki/Get-involved)

### License
The DMPTool project uses the <a href="./LICENSE.md">MIT License</a>.
