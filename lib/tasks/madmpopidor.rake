# frozen_string_literal: true

require "set"
# rubocop:disable Metrics/BlockLength
namespace :madmpopidor do
  desc "Upgrade to v3.0.0"
  task v3_0_0: :environment do
    Rake::Task["madmpopidor:add_structure_question_format"].execute
    Rake::Task["madmpopidor:initialize_template_locale"].execute
    Rake::Task["madmpopidor:load_registries"].execute
    Rake::Task["madmpopidor:seed"].execute
    Rake::Task["madmpopidor:initialize_plan_fragments"].execute
  end

  desc "Initialize Dmp, Project, Meta & ResearchOutputs JSON fragments for the ancient plans"
  task initialize_plan_fragments: :environment do
    Plan.all.each do |plan|
      plan.create_plan_fragments if plan.json_fragment.nil?

      dmp_fragment = plan.json_fragment
      project_fragment = dmp_fragment.project
      meta_fragment = dmp_fragment.meta

      FastGettext.with_locale plan.template.locale do
        #################################
        # PERSON & CONTRIBUTORS FRAGMENTS
        #################################
        # Principal Investigator
        pi_person_data = {
          "nameType" => d_("dmpopidor", "Personal"),
          "lastName" => plan.principal_investigator,
          "mbox" => plan.principal_investigator_email,
          "personId" => plan.principal_investigator_identifier,
          "idType" => plan.principal_investigator_identifier.present? ? "ORCID" : ""
        }
        pi_person = MadmpFragment.fragment_exists?(
          pi_person_data, MadmpSchema.find_by(name: "PersonStandard"), dmp_fragment.id
        )
        if pi_person.eql?(false)
          principal_investigator = project_fragment.principal_investigator
          pi_person = Fragment::Person.create(
            data: pi_person_data,
            dmp_id: dmp_fragment.id,
            madmp_schema: MadmpSchema.find_by(name: "PersonStandard"),
            additional_info: { property_name: "person" }
          )
          principal_investigator.update(
            data: principal_investigator.data.merge("person" => { "dbid" => pi_person.id })
          )
        end

        # Data Contact
        dc_person_data = {
          "nameType" => d_("dmpopidor", "Personal"),
          "lastName" => plan.data_contact,
          "mbox" => plan.data_contact_email
        }
        data_contact = meta_fragment.contact
        dc_person =  MadmpFragment.fragment_exists?(
          dc_person_data, MadmpSchema.find_by(name: "PersonStandard"), dmp_fragment.id
        )

        if dc_person.eql?(false)
          dc_person = Fragment::Person.create(
            data: dc_person_data,
            dmp_id: dmp_fragment.id,
            madmp_schema: MadmpSchema.find_by(name: "PersonStandard"),
            additional_info: { property_name: "person" }
          )
        end
        data_contact.update(
          data: data_contact.data.merge("person" => { "dbid" => dc_person.id })
        )
        #################################
        # PROJECT FUNDINGS
        #################################
        if plan.grant_number.present? || plan.funder_name.present?
          funding = Fragment::Funding.create(
            data: {
              "grantId" => plan.grant_number
            },
            dmp_id: dmp_fragment.id,
            parent_id: project_fragment.id,
            madmp_schema: MadmpSchema.find_by(name: "FundingStandard"),
            additional_info: { property_name: "funding" }
          )
          funding.instantiate
          funding.funder.update(
            additional_info: funding.funder.additional_info.merge(
              "custom_value" => plan.funder_name
            )
          )
        end
      end

      plan.research_outputs.each do |research_output|
        next if research_output.nil? && research_output.json_fragment.present?

        research_output.create_json_fragments
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
    index_path = Rails.root.join("config/madmp/schemas/main/index.json")
    schemas_index = JSON.load(File.open(index_path))

    # Iterate over the schemas of the index.json file
    schemas_index.each do |schema_desc|
      # Read, parse and extract useful data from the JSON schema
      schema_path = Rails.root.join("config/madmp/schemas/main/#{schema_desc['path']}")
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

  # Load registries
  desc "Load JSON registries"
  task load_registries: :environment do
    registries_path = Rails.root.join("config/madmp/registries/index.json")
    registries = JSON.load(File.open(registries_path))

    # Remove all registry values to avoid duplicates
    RegistryValue.destroy_all

    registries.each do |registry_name, values|
      registry_values = []
      registry = Registry.find_or_create_by(name: registry_name) do |r|
        r.name = registry_name
        r.version = 1
      end
      if values.is_a?(Array)
        registry_values = values
      elsif values["path"].present?
        values_path = Rails.root.join("config/madmp/registries/#{values['path']}")
        registry_values = JSON.load(File.open(values_path))
      end
      registry_values.each_with_index do |reg_val, idx|
        RegistryValue.create!(data: reg_val, registry: registry, order: idx)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
