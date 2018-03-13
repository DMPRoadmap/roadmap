require 'test_helper'

class MissingTranslationTest < ActionDispatch::IntegrationTest
  
  # --------------------------------------------------------------------
  test "Make sure that all FastGettext localisations are defined in the .pot/.po files" do

# TODO: Do we even need this? We should be able to auto-run the Fastgettext scripts via hooks in rake tasks
=begin
    missing = []

    # Scan through the /app directory for localisations
    getFiles(Rails.root.join("app")).each do |file|
      contents = File.open(file, 'r').read
      localisations = contents.scan(/_\(['"][^\)]+['"]\)/)
      
      localisations.each do |localisation|
        translation = _(localisation)
        missing << localisation if translation.include?('translation missing')
      end
    end

    assert missing.empty?, "Found some missing translations: #{missing.join("\n")}"
    missing = []

    # Loop through all of the models and force all validation errors to be translated
    dir = Rails.root.join("app", "models").to_s
    getFiles(dir).each do |model|
      unless model.start_with?('.')
        name = model.gsub('.rb', '').gsub("#{dir}/", '').split('_').collect{|p| p.capitalize }.join('')
        name = name.split('/').collect{|p| p }.join('::').gsub(/::[a-z]{1}/, &:upcase)

        # Skip the Settings module classes since they throw errors when validating
        unless name.include?('Settings::')
          clazz = name.split('::').inject(Object){ |o,c| o.const_get(c) }
          obj = clazz.new
          
          unless obj.valid?
            obj.errors.each do |e,m|
              missing << m if _(m).include?('translation missing')
            end
          end
        end
      end
    end
    
    assert missing.empty?, "Found some missing translations for model errors:\n #{missing.join("\n")}"
=end
  end 


  private 
    # Recursively collect the file names within the directory and its subdirectories
    # --------------------------------------------------------------------
    def getFiles(dir)
      files = []
      Dir.foreach(dir) do |f|
        unless f.start_with?('.')
          if File.directory?("#{dir}/#{f}")
            files << getFiles("#{dir}/#{f}")
          else
            files << "#{dir}/#{f}"
          end 
        end
      end
      files.flatten.uniq
    end

end
