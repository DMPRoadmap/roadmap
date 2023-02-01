# Changelog

## DMPTool Releases

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


## Changes from the upstream DMPRoadmap repository
