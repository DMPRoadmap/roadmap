# DMPTool

[![Brakeman Status](https://github.com/CDLUC3/dmptool/workflows/Brakeman/badge.svg?branch=main)](https://github.com/CDLUC3/dmptool/actions)
[![ESLint Status](https://github.com/CDLUC3/dmptool/workflows/ESLint/badge.svg?branch=main)](https://github.com/CDLUC3/dmptool/actions)
[![Rubocop Status](https://github.com/CDLUC3/dmptool/workflows/Rubocop/badge.svg?branch=main)](https://github.com/CDLUC3/dmptool/actions)
[![Pally Status](https://github.com/CDLUC3/dmptool/workflows/Pa11y%20Accessibility%20Checks/badge.svg?branch=main)](https://github.com/CDLUC3/dmptool/actions)
[![MySQL Test Status](https://github.com/CDLUC3/dmptool/workflows/Tests%20-%20MySQL/badge.svg?branch=main)](https://github.com/CDLUC3/dmptool/actions)

The DMPTool is a free, open-source, online system for creating and managing data management plans (DMPs). DMPs are now required by many funding agencies as part of the grant proposal submission process.

Click here for the latest [releases](https://github.com/CDLUC3/dmptool/releases/).

## Infrastructure

The system consists of 2 major components:
- The DMPTool, a DMP authoring tool that is focused on helping researchers write DMPs
- The DMPHub that registers DMP Ids and versions DMP metadata regardless of where the DMP was created

From the user perspective, both of these components appear to be a single unified application. An application load balancer should be used to direct traffic to the appropriate backend component. For example
- `/plans/123` should be directed to the DMPTool Rails based authoring tool so that the user can edit their DMP.
- `/dmps/doi.org/10.12345/A1FF03a` should be directed to the DMPHub's landing page for that DMP ID

The DMPTool Rails application communicates with the DMPHub via the API.
- when the user wants to finalize their DMP and create a DMP ID
- when the user updates data about a DMP that has a registered DMP ID

The DMPHub communicates with the DMPTool via the API.
- when an external system updates DMP ID metadata for a DMP that was created in the DMPTool (e.g. a funder system provides grant information, or a repository provides the DOI of a deposited dataset)

<img src="https://github.com/CDLUC3/dmptool/blob/main/docs/v5/architecture.png" alt="screenshot of DMPTool and DMPHub infrastructure" width="700"/>

Please note that the DMPTool can be run without the DMPHub or when using a separate service (e.g. DataCite) to generate DOIs for your DMPs. Please see the 'The DMPHub' section below for instructions on how to make the necessary changes.

### The DMPTool

The DMPTool is a Rails application (backed by a MySQL or Postgres database) that provides researchers with a click-through wizard for creating a DMP that complies with funder requirements. The wizard has direct links to funder websites, help text for answering questions, and resources for best practices surrounding data management. It is derived from the [DMPRoadmap](https://github.com/DMPRoadmap/roadmap) open source project. DMPRoadmap is being collaboratively developed by members of the [University of California Curation Center (UC3)](https://cdlib.org/services/uc3/), the [Digital Curation Centre (DCC)](https://www.dcc.ac.uk), the [Digital Research Alliance of Canada](https://alliancecan.ca/en) and the [Institut de l'Information Scientifique et Technique](https://www.inist.fr) and contributions from the community.

#### Pre-requisites
Roadmap is a Ruby on Rails application and you will need to have:
* Ruby = 3.0
* Rails = 6.1
* Node >= 18.11
* MySQL >= 8.0 OR PostgreSQL

#### Variations from DMPRoadmap

The DMPTool Rails application has been modified from the baseline DMPRoadmap codebase in the following ways:

- **Homepage:** A complete redesign of the homepage
- **Sigin in/Create account:** The sign in and create account workflows has been overhauled to place more emphasis on logging in via institutional credentials (Shibboleth). All of the DMPTool code for these items have been separated into its own `app/views/branded/shared/` subdirectory. The corresponding JS file can be found at `app/javascript/dmptool/`.
- **Public participating institutions page:** A new Participating Institutions page has been added and is accessible to the public.
- **Public plans:** The DMPTool provides advanced filtering and search for the public plans page. It also allows institutional administrators to 'feature' exemplar plans that their users have made.
- **Related Works:** Admins are able to enter the identifiers for related project outputs (e.g. journal articles, dataset DOIs, etc.) to a DMP's project details page.
- **DMP ID Registration:** The system allows users to register DMP IDs for their plans.
- **OAuth2 compliant API:** The API v2 is OAuth2 compliant and allows partner systems to fetch and download a user's DMPs after the user authorizes the interaction.
- **Navigation:** A complete redesign of the header and footer navigation. All of the custom menus have been placed in `app/views/branded/layouts/`.
- **Styling:** We have added `app/assets/stylesheets/dmptool/**/*.scss` files that gets loaded after the base DMPRoadmap stylesheets
- **Text/Labels:** Various text and labels have been updated.
- **Static Content:** Added a gem to allow the `app/views/branded/static_pages` to be managed via Markdown instead of HTML. Changed the content of existing pages and added new pages

#### Translations

See the [Translations Guide](https://github.com/DMPRoadmap/roadmap/wiki/Translations)

#### Installation

See the [Installation Guide](https://github.com/CDLUC3/dmptool/wiki/installation)

#### Troubleshooting
See the [Troubleshooting Guide](https://github.com/DMPRoadmap/roadmap/wiki/Troubleshooting) on the DMPRoadmap Wiki

### The DMPHub

The DMPHub is an API (backed by a NoSQL document database) that provides DMP ID registration (unique identifiers for DMPs), metadata versioning, publicly accessible and highly available landing pages for DMP ID metadata, and a mechanism for uploading the PDF for a DMP generated outside the DMPTool.

<img src="https://github.com/CDLUC3/dmptool/blob/main/docs/v5/upload_workflow.png" alt="diagram of how the upload DMP form works" width="700"/>

<img src="https://github.com/CDLUC3/dmptool/blob/main/docs/v5/update_workflow.png" alt="diagram of how updates to a DMP ID are handled" width="700"/>

Please see the following repositories:
- [dmp-hub-cfn](https://github.com/CDLUC3/dmp-hub-cfn) - AWS Cloud Formation templates to build the necessary infrastructure for the DMPHub
- [dmp-hub-sam](https://github.com/CDLUC3/dmp-hub-sam) - AWS Lambda code that contains all of the application logic

#### How versioning works

The DMPHub versions a DMP's metadata (and PDF if applicable) when changes are made.

When changes from the external system (DMPTool in most cases) come through, the DMPHub checks the DMP ID item's `modified` date against the internal stored `dmphub_modification_day`. If the dates differ or the modifier is not the system of provenance (the one who created the DMP record) then a new version is created.

When a new version is created the following happens:
- a 'snapshot' is taken of the curent DMP metadata.
- a new `dmproadmap_related_identifier` is added to the 'snapshot' that contains a pointer to the 'latest' version.
- the updated DMP metadata is then merged with any modifications from external systems (e.g. grant ids added by funder systems)
- a new `dmproadmap_related_identifier` is added to the DMP metadata that is a pointer to the 'snapshot'

Any subsequent requests for the DMP ID display the updated metadata. The prior version is then accessible via an 'All versions' menu item on the landing page, or directly via the `dmproadmap_related_identifier` value

<img src="https://github.com/CDLUC3/dmptool/blob/main/docs/v5/versioning.png" alt="screenshot of an illustrated guide to how DMP ID versioning works" width="700"/>

#### Disabling or replacing the DMPHub

You can run the DMPTool Rails application without the DMPHub component discussed here. To do that you can do one of the following:
- opting not to allow users to generate DMP IDs at all
  - To do this, simply set both the `enable_dmp_id_registration`, `enable_orcid_publication`, and `dmphub_active` values to `false` in the `config/dmproadmap.yml` file.
- by using DataCite directly to generate DMP IDs
  - To do this you must have a registered account with DataCite
  - Set your DataCite shoulder and credentials in the `credentials.yaml.enc` file
  - Set the `dmphub_active` variable to `false` and the `datacite_active` variable to `true` in the `config/dmproadmap.yml`.
- by using another service to generate DMP IDs
  - Create a new DMP ID service by copying the `app/services/external_apis/datacite_service.rb` and `config/initializers/external_apis/datacite.rb` files and renaming them to something like `my_service.rb`
  - Add any necessary configuration options to `config/configs/dmproadmap_config.rb` and `config/dmproadmap.yml`
  - Update the `app/services/dmp_id_service.rb` file to add your new service to the `minter` function
  - If others might find your new service useful, consider contributing it back to this repository as a pull request

## Support

Issues should be reported on [Github Issues](https://github.com/CDLUC3/dmptool/issues)
Please be advised though that we can only provide support for the [DMPTool](https://dmptool.org). This code is offered as open source and we can only provide limited support for your local installation.

Issues will be triaged by our team and if applicable will be moved/opened in the DMPRoadmap repository.

## Contributing

See the [Contributing Guide](https://github.com/DMPRoadmap/roadmap/wiki/Get-involved).

## License
The DMPTool project uses the <a href="./LICENSE.md">MIT License</a>.
