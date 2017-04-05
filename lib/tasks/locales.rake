namespace :locales do
  
  desc "Generate JSON locale files from the Gettext PO and POT files"
  task po2json: :environment do
    # First run the gettext_i18n_rails_js gem's task to create the JSON files
    Rake::Task["gettext:po_to_json"].invoke
    
    # The gem places the JSON files into app/assets/javascripts/locale. That dir is for branded content
    # though so we need to move these files to lib/assets/javascripts/locale so that they are picked up
    # by git and contributed to the repo
    if Dir.exist?('app/assets/javascripts/locale')
      puts "moving newly created JSON files from app/assets/javascripts/ to lib/assets/javascripts/"
      FileUtils.remove_dir('lib/assets/javascripts/locale/', force: true)
      FileUtils.mv('app/assets/javascripts/locale', 'lib/assets/javascripts/', force: true)
    else
      puts "Warning: It doesn't appear as though the JSON files were generated. Make sure that the gettext_i18n_rails_js gem is installed."
    end
  end
  
end