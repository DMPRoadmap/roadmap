require 'set'
namespace :madmpopidor do
  
  desc "Initialize Dmp, Project, Meta & ResearchOutputs JSON fragments for the ancient plans"
  task initialize_plan_fragments: :environment do
    Plan.all.each do |plan|
      if plan.json_fragment.nil?
        plan.create_plan_fragments()
      end
      
      plan.research_outputs.each do |research_output|
        unless research_output.nil?
          if research_output.json_fragment.nil?
            research_output.create_or_update_fragments()
          end
        end
      end
    end
  end
  
  desc "Initialize the template locale to the default language of the application"
  task initialize_template_locale: :environment do
    languages = Language.all
    Template.all.each do |template|
      if languages.find_by(abbreviation: template.locale).nil?
        template.update(locale: Language.default.abbreviation)
      end
    end
  end

  # Load templates form an index file
  desc "Load JSON templates for structured questions in the database"
  task load_templates: :environment do
    # Read and parse index.json file
    index_path = Rails.root.join("config/schemas/main/index.json")
    schemas_index = JSON.load(File.open(index_path))

    # Iterate over the schemas of the index.json file
    schemas_index.each do |schema_desc|
      # Read, parse and extract useful data from the JSON schema
      schema_path = Rails.root.join("config/schemas/main/#{schema_desc['path']}")
      json_schema = JSON.load(File.open(schema_path))
      title = json_schema["title"]
      classname = schema_desc["classname"]

      begin
        schema = MadmpSchema.find_or_initialize_by(name: title) do |s|
          s.label = title
          s.name = title
          s.version = 1
          s.org_id = Org.first.id
          s.classname = classname
        end
        schema.update(schema: json_schema.to_json)
      rescue ActiveRecord::RecordInvalid
        p "ERROR: template #{title} is invalid (model validations)"
      end
    end

    # Replace all "template_name" key/values with "schema_id" equivalent in loaded schemas
    MadmpSchema.all.each do |schema|
      begin
        schema.update(schema: MadmpSchema.substitute_names(schema.schema))
      rescue ActiveRecord::RecordNotFound => e
        p "ERROR: template name substitution failed in #{schema.name}: #{e.message}"
        next
      end
    end
  end
end
