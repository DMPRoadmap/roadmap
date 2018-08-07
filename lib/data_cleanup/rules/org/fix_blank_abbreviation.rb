module DataCleanup
  module Rules
    module Org
      class FixBlankAbbreviation < Rules::Base

        YAML_FILE_PATH = Rails.root.join("lib", "data_cleanup", "rules", "org",
                                         "fix_blank_abbreviation.yml")

        def description
          "Fix blank abbreviation on Org"
        end

        def call
          if File.exists?(YAML_FILE_PATH)
            YAML.load_file(YAML_FILE_PATH).each do |attributes|
              attributes   = attributes.with_indifferent_access
              id           = attributes['id']
              name         = attributes['name']
              abbreviation = attributes['abbreviation']
              log("Adding abbreviation #{abbreviation} to Org '#{name}'")
              ::Org.where(name: name, id: id).update_all(abbreviation: abbreviation)
            end
          else
            raise "Please create a YAML file at #{YAML_FILE_PATH}"
          end
        end
      end
    end
  end
end
