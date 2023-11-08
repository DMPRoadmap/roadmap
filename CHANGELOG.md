# Changelog

## v4.2.0

**Note this upgrade is mainly a migration from Bootstrap 3 to Bootstrap 5.** 

Note that this will have a significant impact on any scss and html customizations you may have made to your fork of this project. 

The following links will be helpful:

[Get started with Bootstrap v5.2.3](https://getbootstrap.com/docs/5.2/getting-started/introduction/)<br>
[Migrating to v4](https://getbootstrap.com/docs/4.0/migration)<br>
[How to Migrate from Bootstrap Version 3 to 4](https://designmodo.com/migrate-bootstrap-4/)<br>
[Migrating to v5](https://getbootstrap.com/docs/5.0/migration)<br>
[How to Migrate from Bootstrap Version 4 to 5](https://designmodo.com/migrate-bootstrap-5/)<br>
[Use Bootstrap 5 with Ruby on Rails 6 and webpack](https://medium.com/daily-web-dev/use-bootstrap-4-with-ruby-on-rails-6-and-webpack-fe7300604267)<br>
[What happened to $grid-float-breakpoint in Bootstrap 4. And screen size breakpoint shift from 3 -> 4](
https://bibwild.wordpress.com/2019/06/10/what-happened-to-grid-float-breakpoint-in-bootstrap-4-and-screen-size-breakpoint-shift-from-3-4/)<br>
[What are media queries in Bootstrap 4?](https://www.educative.io/answers/what-are-media-queries-in-bootstrap-4)<br>
   
#### Key changes
    
- Node  package changes:
  * Changed version of `bootstrap "^3.4.1"` --> `"^5.2.3"`
  * Added  `@popperjs/core.`
  * Removed `bootstrap-3-typeahead, bootstrap-sass & popper.js`.
- Stylesheet changes
  * In `app/assets/stylesheets/application.scss`:
    + removed `bootstrap-sass` import <br>
      and replaced with<br>
       `@import "../../../node_modules/bootstrap/scss/bootstrap";`

  * The order of the `import` statements have been changed to import the `blocks/` and `utils/` after the default bootstrap stylesheets

  * In `app/assets/stylesheets/blocks/`:
    + Replaced in relevant files:
      + `@use "../../../../node_modules/bootstrap-sass/assets/stylesheets/_bootstrap.scss" as * ;`<br>
         with <br>
         `@use "../../../../node_modules/bootstrap/scss/bootstrap" as *;`
    + Enclosed all division calculations using symbol `/` with `calc()` function,<br> 
      e.g., replaced<br>
         `padding-right: $grid-gutter-width / 2;`<br>
      with<br>
         `padding-right: calc($grid-gutter-width / 2);`<br>
    + Replaced with breaking media queries since Bootstrap 3:
      - `@media (max-width: $grid-float-breakpoint-max) {}`<br>
        with<br>
        `@include media-breakpoint-down(md){}`
    
      - `@media (max-width: $grid-float-breakpoint-max) {}`<br>
        with<br>
        `@include media-breakpoint-down(md) {}`
- Deleted `app/javascript/src/utils/popoverHelper.js`
- Using Bootstrap 5 accordion and spinner now. This replaces bespoke versions used.
  + The spinner block now uses class `.d-none` instead of `.hidden` to hide.
- Bootstrap 5 dropped panels, thumbnails, wells and form-groups. So pages with them updated with Bootstrap 5 replacements. 
  + All views with css classes `.panel, .panel-body, panel-*`. Have panel replaced
    by card to give `.card, .card_body, .card-*`, etc. As `.panel-default` and some other
    panel css classes don't have card equivalents with same suffixes we have
    added these classes temporarily in _cards.sccs. For example, 
    `.card-default`, etc.
   + **Note:**  We have retained `.form-group` for use in grouping form inputs as we reference it in 
    `src/utils/requiredField.js` line 20: const label = target.closest('.form-group').find('label');.
- Pages with css classes nav `.nav` and `.navbar` updated to  work with Bootstrap 5:
  + CSS classes changes:
    -  `.nav .navbar-nav` combination -->  `.navbar-nav`
    - `.navbar-toggle` --> `.navbar-toggler`
    - multiple spans in `.navbar-toggle` button with class `.icon-bar`<br>  --> single span with `.toggler-icon`
    - Lists with `.nav .navbar-nav` have class `.nav-item` added to list elements.
    - Dropdown list items with class `.dropdown` in navigation bar have class `.nav-item` and links in the lists have `.nav-link` added.
  + SCSS files `app/assets/stylesheets/blocks/_navbars.scss` and `app/assets/stylesheets/blocks/_navs.scss` updated. 
+ Data attributes changes required by Bootstrap 5 (as used by accordion and dropdown buttons):
  - `data-display` --> `data-bs-display`
  - `data-parent` -->`data-bs-parent`
  - `data-target` -->`data-bs-target`
  - `data-toggle` --> `data-bs-toggle`
+ Notifications now use classes `.d-block` and `.d-none` to show and hide respectively.
+ Bootstrap 5 Popover added to some dropdown-menu items by adding attribute `data-bs-toggle="popover"`.
- `float-start` and `float-end` replaced with `pull-left` and `pull-right` respectively

## V4.1.1

### Added
- Added `MORE_INFO` and `LESS_INFO` JS constants (for the Research Outputs feature)
- Added a .gitkeep file to the app/assets/builds directory to address potential issues when building the application.css file during production deploys #3314

### Fixed
- Updated the default font on the 'Download page' to be 'Roboto, Arial, Sans-Serif'
- Fixed an issue with API V0 that was causing a 500 Internal Server error
- Solved issue where spring was loaded in production mode : ran `bin/spring binstub --all`
- Updated fontawesome to V6


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

### Bug Fixes

## v4.0.2

### Added
- Added CHANGELOG.md and Danger Github Action [#3257](https://github.com/DMPRoadmap/roadmap/issues/3257)
- Added validation with custom error message in research_output.rb to ensure a user does not enter a very large value as 'Anticipated file size'. [#3161](https://github.com/DMPRoadmap/roadmap/issues/3161)
- Added popover for org profile page and added explanation for public plan

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
