# Changelog

## [2.1.3+portage-1.0.9] - 2021-04-19

### Fixed
 - Fix bug when copying new plan url on template paginated view

### Removed
 - Pulled unused javascript validation when creating a new user

### Changed
 - Changed redirect path when error in signup form

## [2.1.3+portage-1.0.8] - 2021-04-06

### Added
 - Include reCAPTCHA Security check for account creation
 - Add feature to make Templates public

### Fixed
 - Arrange organization links in header layout

## [2.1.3+portage-1.0.7] - 2021-03-08

### Added
 - Add visibility options for plans
 - Make public plans downloadable

## [2.1.3+portage-1.0.6] - 2021-03-02
 
### Fixed
 - Vertical alignment for organization name

## [2.1.3+portage-1.0.5] - 2021-03-02

### Added
 - Add content to help page

### Changed
 - Update translation files 

### Fixed
 - Fix small errors for French content

## [2.1.3+portage-1.0.4] - 2021-02-28

### Fixed
 - Fix problem when searching for templates when using raw SQL queries

## [2.1.3+portage-1.0.3] - 2021-02-27

### Changed
 - Update translation files

### Fixed
 - Fix bug with Question options not being translated

## [2.1.3+portage-1.0.2] - 2021-02-26

### Changed
 - Update translation files
### Fixed
 - Fix bug when importing templates from rake task

## [2.1.3+portage-1.0.1] - 2021-02-24

### Added
 - Add content to landing page with new links and french versions for same sites

### Changed
 - Change database connection encoding

## [2.1.3+portage-1.0.0] - 2021-02-16

### Added
 - Add content based on the feedback from our French language review
 - Add translated read access method for Template and Plan content
 - Add rake tasks to export and import templates
 - Include application name on translation
 - Add locale permanency after logout
 - Add tinymce translations
 - Add localized DMP assistant logo
 - Add translation for Theme content
 - Add configuration for ActionMailer to use SMTP
 - Add crafted favicon to be served as static content
 - Render a 404 error page when record is not found
 - Add configuration for rollbar calls
 - Add configuration for wicked_pdf proxy
 - Add Google analytics
 - Add rake tasks to remove span accounts

### Removed
 - Remove references of "Do not reply" on mailers as we are now expecting replies from application emails
 - Remove all calls trying to translate an empty string
 - Remove autofill for plan grant number
 - Remove institutional credential from profile edit as we are not currently using Shibboleth
 - Deactivate Shibboleth authentication

### Changed
 - Update response to reset password email to suggest a direct response
 - Update translation files
 - Change the "number to text" js package to a newer version with continued support
 - Change translation.io gem to our own customization to allow database translation support
 - Change French date format localization
 - Update static content pages
 - Change CSS Branding for navbar
 - Replace portage orange in favor of white as 2nd UI color
 - Change logger to syslog

### Fixed
 - Fix random log warnings
 - Address problems with tests using tinymce
 - Fix locales tests
 - Fix issues with tests taking too long
 - Fix support for nulldb adapter
 - Fix 500 error when downloading usage statistics

