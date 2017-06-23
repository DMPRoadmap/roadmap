// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs

//= require vendor/v1.js
//= require vendor/jquery-ui.min.js
//= require vendor/jquery-accessible-autocomplet-list-aria.js
//= require vendor/jquery.placeholder.js
//= require vendor/jquery.tablesorter.min.js
//= require vendor/jquery.timeago.js
//= require tinymce-jquery

//= require i18n
//= require i18n/translations
//= require_tree ./locale
//= require gettext/all

//= require dmproadmap.js
//= require dmproadmap/utils.js
//= require dmproadmap/accordions.js
//= require dmproadmap/forms.js
//= require dmproadmap/modals.js
//= require dmproadmap/tables.js
//= require dmproadmap/tabs.js

// We pull the ones below in here because they were not functioning for the modals unless
// the were loaded at this level
//= require views/shared/login_form.js
//= require views/shared/register_form.js


