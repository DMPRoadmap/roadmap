# frozen_string_literal: true

require "set"
# rubocop:disable Metrics/BlockLength
namespace :madmpopidor do
  desc "Upgrade to v3.0.0"
  task v3_0_0: :environment do
    Rake::Task["madmpopidor:add_structure_question_format"].execute
    Rake::Task["madmpopidor:initialize_template_locale"].execute
    Rake::Task["madmpopidor:seed"].execute
    Rake::Task["madmpopidor:initialize_plan_fragments"].execute
  end

  desc "Initialize Dmp, Project, Meta & ResearchOutputs JSON fragments for the ancient plans"
  task initialize_plan_fragments: :environment do
    Plan.all.each do |plan|
      plan.create_plan_fragments if plan.json_fragment.nil?

      plan.research_outputs.each do |research_output|
        next if research_output.nil? && research_output.json_fragment.present?

        research_output.create_or_update_fragments
      end
    end
  end

  desc "Add Structured question format in table"
  task add_structure_question_format: :environment do
    if QuestionFormat.find_by(title: "Structured").nil?
      QuestionFormat.create!(
        {
          title: "Structured",
          description: "Structured question format",
          option_based: false,
          formattype: 9,
          structured: true
        }
      )
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

  desc "Seeds the database with the madmp data"
  task seed: :environment do
    Rake::Task["madmpopidor:load_templates"].execute
    load(Rails.root.join("db", "madmp_seeds.rb"))
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
# rubocop:enable Metrics/BlockLength
