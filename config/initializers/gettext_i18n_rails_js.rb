GettextI18nRailsJs.config do |config|
  config.output_path = "lib/assets/javascripts/locale"

  config.handlebars_function = "__"
  config.javascript_function = "__"

  config.jed_options = {
    pretty: false
  }
end