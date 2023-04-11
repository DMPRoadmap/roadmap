# Changelog

## DMPTool Releases

### v4.1.0
**Note: This version includes a change to the research_outputs table!** We have added a new `research_outputs.research_output_type` field that stores a string value. It is a replacement for the old `research_outputs.output_type` integer field. You will need to run: `bin/rails db:migrate && bin/rails v4:upgrade_4_1_0` to make the change to your data model and migrate your existing data to the new field.

- Added the following columns to the `templates` table
  - `enable_research_outputs`
  - `user_guidance_output_types`
  - `user_guidance_repositories`
  - `user_guidance_metadata_standards`
  - `user_guidance_licenses`
  - `customize_output_types`
  - `customize_repositories`
  - `customize_metadata_standards`
  - `customize_licenses`
- Updated the Templates model (and RSpec factory and tests) to use new field
- Created the Template Preferences View
- Added column `research_output_type` to the `research_outputs` table
- Added `v4:upgrade_4_1_0` rake task to migrate data from `output_type` and `output_type_description` to the new `research_output_type` field
- Updated the ResearchOutput model (and RSpec factory and tests) to use new field
- Replaced the old `output_types` enum on the ResearchOutput model with `DEFAULT_OUTPUT_TYPES` array
- Updated presenters (and RSpec tests) and controller to work with the new field
- Created table template_licenses
  - Created UI to save preferred Licenses for a Template
- Created table template_output_types
  - Created UI to save preferred Output Types for a Template
- Created table template_repositories
  - Customize modal search to populate this relation
- Created table template_metadata_standards
  - Customize modal search to populate this relation
- Modify repositories table to allow for the definition of customized repositories for a template.
  - UI to create customized repositories
  - UI to select customized, preferred and/or standard repositories for a research output.

### v4.0.8

### Features
- Update to the Org admin Plans page that will now show the date that feedback was requested. [#434](https://github.com/CDLUC3/dmptool/issues/434)
- Changed the language around the confusing checkbox/option text on the download plan page (for PDF download) and changed defaults so that only the section heading and question text are enabled by default. [#435](https://github.com/CDLUC3/dmptool/issues/435)

### Bug Fixes:
- Fixed an issue causing the mouse pointer to change to a text icon when hovering over hyperlinks for Chrome and Firefox. It now correctly displays the hand pointer [issue #445](https://github.com/CDLUC3/dmptool/issues/445)
- Patch [issue #447](https://github.com/CDLUC3/dmptool/issues/447) that was deleting all prior related identifiers when a user adds a new related identifier on the 'Follow up' tab.
- Patch Github Actions to lock Node at v16.6 to deal with a version compatability issue with openSSL
- Attempt to patch issue that was causing registry_orgs search by name to fail for Postgres distributions that is causing Rspec tests to fail for `spec/services/api/v2/deserialization/*.rb`. Perhaps someone out there with Postgres can debug, fix and submit a PR.

### v4.0.5
This version includes changes from [DMPRoadmap release v4.0.2](https://github.com/DMPRoadmap/roadmap/releases/tag/v4.0.2) see the release notes for details.

#### New Feature / Functionality changes:
- Added 'Preregistration' to list of available 'Work Type' values for research outputs on the Follow-up tab

#### Bug Fixes:
- Patched issue that was causing Templates to become 'organizationally_visible' when the title or links were updated.
- Refactored the Public Plans page to be more efficient with memory usage [#419](https://github.com/CDLUC3/dmptool/issues/419)
- Fixed Subject of emails sent out when the user's password changes so that it no longer says 'Unauthorized password change' which was alarming.

#### Maintenance:
- Updated all gem and JS dependencies
- Removed rack_attack gem
- Installed rubocop-performance gem and updated DMPTool code to comply with suggestions. Then commented reference to the gem in .rubocop because it wanted to make too many changes to the base DMPRoadmap codebase. Will submit a PR to that repo directly for those changes and will then uncomment the ref.

### v4.0.4
#### New Feature / Functionality changes:
- Institutional administrators can now update the URL that their users are sent to when clicking their logo. This can now be managed on the Org Details page. #418
- Updated the Finalize/Publish page so that the Plan visibility and Register DMP ID sections are more similar and intuitive #399
- Added a new 'Follow Up' tab to the plan edit page. This tab is intended for researchers or institutional administrators to update Funding information and connect associated research outputs with the original DMP (e.g. publications, dataset DOIs, etc.). Note that these associated research outputs were previously only updatable by institutional administrators on the Project Details page.
- Updated the edit plan tabs so that they incorporate the new 'Follow up' tab and now follow a logical order. They now are: Project Details, Collaborators, Write Plan, Research Outputs, Request Feedback, Finalize, Download, Follow Up

#### Bug Fixes:
- Research Outputs now appear in the CSV and TXT versions #406
- Fixed an issue that was causing the DOCX version of the plan from displaying an error in MS Word when opening the document
- Fixed an issue with the sans-serif font used in PDF generation. Switched from Helvetica (which is no longer downloadable for free) to Roboto and also updated spacing between questions/sections.
- Fixed an issue that was preventing an institutional admin from adding more than one URL/link on the Org Details page #413  #405
- Fixed an issue that was preventing associated research outputs from being deleted #372
- Fixed an issue with the emails sent out after the plan's visibility changes #416
- Fixed an issue where failures to save the plan were not aborting the steps that publish info to ORCID and register DMP IDs
- Fixed an issue where a failure to create the User in the SSO sign up workflow was adding the user's unique ID to the identifiers table with a nil reference to users.
- Updated some deprecated use of `setMode` to `mode.set` in TinyMCE JS.
- Updated algorithm that matches a user's email domain to ROR institution home pages. So that:
  - '@foo.edu' will match http://foo.edu, https://foo.edu, https://subdomain.foo.edu
  - '@foo.edu' will NOT match http://foobar.edu, http://foo.bar.edu, http://barfoo.edu
- Fixes to RSpec tests so that they stop randomly failing during CI tests

#### Maintenance:
- Updated translations
- Updated all gem and JS dependencies
- Adjusted rack_attack config to help research #419
- Added this CHANGELOG.md

---
## Changes from the upstream DMPRoadmap repository

## v4.0.2

### Added

- Added CHANGELOG.md and Danger Github Action [#3257](https://github.com/DMPRoadmap/roadmap/issues/3257)
- Added validation with custom error message in research_output.rb to ensure a user does not enter a very large value as 'Anticipated file size'. [#3161](https://github.com/DMPRoadmap/roadmap/issues/3161)
- Added popover for org profile page and added explanation for public plan

### Fixed

- Fixed an issue that was preventing uses from leaving the research output byte_size field blank
- Patched issue that was causing template visibility to default to organizationally visible after saving
- Froze mail gem version [#3254](https://github.com/DMPRoadmap/roadmap/issues/3254)
- Updated the CSV export so that it now includes research outputs
- Updated sans-serif font used in PDF downloads to Roboto since Google API no longer offers Helvetica
- Fixed discrepencies with default/max per_page values for API and UI pagination
- Updated JS that used to call the TinyMCE `setMode()` function so that it now calls `mode.set()` because the former is now deprecated.
- Patched an issue that was causing a template's visibility to change to 'organizationally_visible' when saving on the template details page.
- Froze mail gem version [#3254](https://github.com/DMPRoadmap/roadmap/issues/3254)
- Fixed an issue with the Rails 6 keyword arguments change that was causing the `paginable_sort_link` to fail
- Updated sans-serif font used in PDF downloads to Roboto since Google API no longer offers Helvetica
- Fixed discrepencies with default/max per_page values for API and UI pagination
- Updated the CSV export so that it now includes research outputs
- Fixed an issue with the Rails 6 keyword arguments change that was causing the `paginable_sort_link` to fail
- Froze mail gem version [#3254](https://github.com/DMPRoadmap/roadmap/issues/3254)
- Fixed an issue with the Rails 6 keyword arguments change that was causing the `paginable_sort_link` to fail
- Updated sans-serif font used in PDF downloads to Roboto since Google API no longer offers Helvetica

### Changed

- Added scss files to EditorConfig
- Change csv file name for statistics from 'Completed' to 'Created'
