# Changelog

## DMPTool Releases

### v4.1.5

- Added the ability for users to change the font size, font color, text alignment in the TinyMCE editors. See app/javascript/utils/tinymce.js.
- Removed Google Analytics from the `app/views/branded/layouts/_analytics.html.erb` and replaced with logic to support Matomo tracking. This requires an account with Matomo and setting up some configuration settings. #490
- Updated the template edit page so that ALL admins will now see the visibility flags. Originally this would only appear in scenarios when the org was a funder and institution/organization. The logic however seems to have been incorrectly setting the template visibility under certain scenarios so there is a need for the user to be able to change it themselves. #474
- Updated the finalize tab so that co-owners see a red 'X' and a note letting them know that only the creator of the plan can register a DMP ID #485
- Added new controller action for creating a plan from the links on the funder requirements page and consolidated logic shared by the new action and the old 'create' action. Fixes bug #488
- Fixed a bug that was causing the org details page to throw a 500 error when the org is a funder and had nil values set for their 'Create plan via api' email subject and body #363
- Fixed an issue that was causing the wrong plan visibility to be shown when the user's role for the plan was not owner or co-owner #483
- Fixed a bug that was getting triggered when an API client had more than one redirect URIs defined #472
- Fixed a bug that was returning the plans associated with the API client's user instead of the OAuth2 resource owner's plans when the user has no plans defined. For example if external system A received authorization to access Jane Doe's plans, but Jane has no plans, the API was returning all of system A's owner/user's plans #475
- Updated gem and JS dependencies

### v4.1.4

- Fixes an issue where a failure from the uc3-citation gem was forcing the RelatedIdentifier model into an endless loop. Limit on number of Research Outputs? Issue #479.
- Added users.ui_token in preparation for v5 work. Added the api/v2/me endpoint to fetch the currently logged in user's info which will be used by future React pages. UI token is generated/regenerated when the user logs in and deleted when they log out.
- Updated JS and gem dependencies

### v4.1.3

- Patch bug when updating a research output that has no selected repos or standards

### v4.1.2
- Update modal search for repositories to allow researchers to define custom repositories that are not a part of the re3data registry
- Update modal search for metadata standards to allow researchers and template admins to define custom standards that are not a part of the rda registry
- Refactor custom repository creation for template administrators. Moved functionality into existing modal search window accessed via new 'My repository is not listed' button
- Updated gem and JS dependencies

### v4.1.1
- Patch for scenarios where empty custom repositories were being included on form submission in the Preferences tab which was causing the Template.update to fail
- Updated gem and JS dependencies

### v4.1.0
**Note: This version includes a change to the research_outputs table!** We have added a new `research_outputs.research_output_type` field that stores a string value. It is a replacement for the old `research_outputs.output_type` integer field. You will need to run: `bin/rails db:migrate && bin/rails v4:upgrade_4_1_0` to make the change to your data model and migrate your existing data to the new field.

Updated the Admin Template edit page with a new 'Preferences' tab. This new tab allows admins to specify whether or not the Research Outputs tab will be available to the researcher when filling out their plan. If enabled, the admin can specify preferred/recommended output types, licenses, metadata standards and repositories. They can also provide guidance to the research to help them with their selections of those items.

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
- Removed 'Embargoed' from the list of Research Output Type's initial access level and changed the names of the other options. (Left the enum intact on the model for now so that data can be migrated)
- Added a new 'OTHER' license type (does not appear in JSON output because it has no valid URI)
- Added column `research_output_type` to the `research_outputs` table
- Added `v4:upgrade_4_1_0` rake task to migrate data from `output_type` and `output_type_description` to the new `research_output_type` field. The task also adds a default 'OTHER' license and migrates `resource_output.access` from embargoed to closed
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

## v4.1.0

**Note this upgrade is a migration from Ruby v2.7.6 to v3.0.5.** Note that this could have an impact on any customizations you may have made to your fork of this project. Please see https://www.fastruby.io/blog/ruby/upgrades/upgrade-ruby-from-2.7-to-3.0.html for further information on what to check. In particular, please note the changes to the way [Ruby 3 handles keyword arguments](https://www.ruby-lang.org/en/news/2019/12/12/separation-of-positional-and-keyword-arguments-in-ruby-3-0/)

**Note that the Webpacker gem has been removed in favor of jsbundling-rails.** This was done in preparation for the future migration to Rails 7. See [issue #3185](https://github.com/DMPRoadmap/roadmap/issues/3185) for more details on this change. If, after migrating to this version, you see 'Sprockets' related errors in your application you will need to rebuild you asset library. To do this run `bin/rails assets:clobber && bin/rails assets:precompile` from the project directory.

All gem and JS dependencies were also updated via `bundle update && yarn upgrade`

### Upgrade to Ruby 3

- Upgrade to Ruby version 3.0.5 [#3225](https://github.com/DMPRoadmap/roadmap/issues/3225)
- Bumped all Github actions to use ruby 3.0
- Removed `.freeze` from Regex and Range constants since those types are already immutable
- Fixed Rubocop complaint about redundancy of `r.nil? ? nil : r.user`, so changed it to `r&.user` in `app/models/plan.rb`
- Fixed Rubocop complaint about redundant `::` in config.log_formatter = `::Logger::Formatter.new` in `config/environments/production.rb`
- Froze `lib/deprecators/*.rb` constants that were Strings
- Updated places that were incorrectly using keyword args. See [this article](https://makandracards.com/makandra/496481-changes-to-positional-and-keyword-args-in-ruby-3-0) for an overview

#### Upgraded TinyMCE to v6

- Upgraded TinyMCE to v6 (v5 EOL is April 20 2023)
- Adjusted JS code to conform to new TinyMCE version
- Adjusted views to work with the new version
- Updated variables.scss file to fix issue with button text/background color contrast
- Updated blocks/_tables.scss to fix issue with dropdown menu overlap against table
- updated config/initializers/assets.rb to copy over the tinymce skins and bootstrap glyphicons to the public directory so that they are accessible by TinyMCE and Bootstrap code

#### Removed webpacker gem

As Webpacker is no longer maintained by the Rails community, we have replaced it by `jsbundling-rails` and `cssbundling-rails` for the Javascript & CSS compilation.

- Removed `webpacker` gem
- Added `jsbundling-rails`
- Updated webpack and its configuration to V5
- Moved `app/javascript/packs/application.js` to `app/javascript/application.js`
- Removed `ruby-sass` gem
- Added `cssbundling-rails` gem and DartSass JS library
- Updated SASS stylesheets following the migration to the latest version of the `sass` package (See below).
- Removed `font-awesome-sass` gem and used `@fortawesome/fontawesome-free` npm package
- Issue with `@import 'font-awesome-sprockets';` line in `app/assets/stylesheets/application.scss`. Removed that line after referring to the latest font-awesome install/setup guide which no longer includes it.

With the removal of Webpacker, the Javascript/SASS code is no longer automaticaly compiled when using the `rails server` command. It has been replaced by the `bin/dev` command that launch the rails server and the processes that watch for changes in the SASS and Javascript code.

#### SASS update : removal of the `@import` keyword

With the removal of the webpacker gem, the DartSass package has been installed to ensure the compilation of the Sass stylesheet and with it, an update to the Sass version used by the code :
- `@import` keyword for custom stylesheets has been removed (although we can still import stylesheets from externals packages) and has been replaced by `@use` and `@forward`
- An `_index.scss` file have to be created in folders containing multiple sass files. Each file have to be included in the index with the `@use` or `@forward` keyword.
- In most cases `@import` can be replaced by `@use` when importing a file.
- `@forward` makes mixins, functions and variables available when a stylesheet is loaded.
- When imported, Sass variables are now namespaced with the file name in which they are declared (ex : `color: colors.$red`). A namespace can be renamed (ex : `@use "colours" as c;`) or removed when included (ex : `@use "colours" as *;`)
- Sass variables are no longer declared globally and have to be included in files where they are used.
For more detailed explanation, please refer to this video : https://www.youtube.com/watch?v=CR-a8upNjJ0

### Introduction of RackAttack
[Rack Attack](https://github.com/rack/rack-attack) is middleware that can be used to help protect the application from malicious activity. You can establish white/black lists for specific IP addresses and also define rate limits.

- Using Rack-attack address vulnerabilities pointed out in password reset and login: there was no request rate limit.[#3214](https://github.com/DMPRoadmap/roadmap/issues/3214)

### Cleanup of Capybara configuration
- Cleaned up Gemfile by:
  - removing gems that were already commented out
  - removed selenium-webdriver and capybara-webmock
  - removing version restrictions on: danger, font-awesome-sass, webdrivers
- Cleaned up `spec/rails_helper.rb` and `spec/spec_helper.rb`
- Simplified the `spec/support/capybara.rb` helper to work with the latest version of Capybara and use its built in headless Chrome driver

### Rubocop updates
- Installed rubocop-performance gem and made suggested changes
- Added lib tasks as exclusive from debugger rubocop check after rubocop upgrading to >= v1.45 [#3291](https://github.com/DMPRoadmap/roadmap/issues/3291)

### GitHub actions updates
- Added node version specification (v16) to eslint, PostgreSQL and MySQL github action to eliminate `digital routine enveloped` error [#319](https://github.com/portagenetwork/roadmap/issues/319)

### Enhancements
- Added enum to the funding status attribute of plan model to make the dropdown of 'funding status' being translatable
- Allow users to download both single phase and  in PDF, TEXT and DOCX format. CSV file can only download single phase instead of all phases.

## v4.0.2

### Added
- Added CHANGELOG.md and Danger Github Action [#3257](https://github.com/DMPRoadmap/roadmap/issues/3257)
- Added validation with custom error message in research_output.rb to ensure a user does not enter a very large value as 'Anticipated file size'. [#3161](https://github.com/DMPRoadmap/roadmap/issues/3161)
- Added popover for org profile page and added explanation for public plan
- Fixed template visibility issues
- Fix to research outputs byte size which was not allowing nil

 - Added rack-attack version 6.6.1 gem. https://rubygems.org/gems/rack-attack/versions/6.6.1

### Fixed
- Fixed an issue that was preventing uses from leaving the research output byte_size field blank
- Patched issue that was causing template visibility to default to organizationally visible after saving
- Froze mail gem version [#3254](https://github.com/DMPRoadmap/roadmap/issues/3254)
- Updated the CSV export so that it now includes research outputs
- Updated sans-serif font used in PDF downloads to Roboto since Google API no longer offers Helvetica
- Fixed discrepencies with default/max per_page values for API and UI pagination
- Updated JS that used to call the TinyMCE `setMode()` function so that it now calls `mode.set()` because the former is now deprecated.
- Patched an issue that was causing a template's visibility to change to 'organizationally_visible' when saving on the template details page.
- Fixed an issue with the Rails 6 keyword arguments change that was causing the `paginable_sort_link` to fail

### Changed

- Added scss files to EditorConfig
- Change csv file name for statistics from 'Completed' to 'Created'
