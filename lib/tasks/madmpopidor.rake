# frozen_string_literal: true

# rubocop:disable Naming/VariableNumber
namespace :madmpopidor do
  desc 'Upgrade to v3.0.0'
  task v3_0_0: :environment do
    p 'Upgrading to DMP OPIDoR v3.0.0'
    p '------------------------------------------------------------------------'
    Rake::Task['madmpopidor:add_structure_question_format'].execute
    Rake::Task['madmpopidor:initialize_template_locale'].execute
    Rake::Task['madmpopidor:load_registries'].execute
    Rake::Task['madmpopidor:seed'].execute
    Rake::Task['madmpopidor:initialize_plan_fragments'].execute
    p '------------------------------------------------------------------------'
    p 'Upgrade complete'
  end

  desc 'Upgrade to v3.4.0'
  task v3_4_0: :environment do
    p 'Upgrading to DMP OPIDoR v3.4.0'
    p '------------------------------------------------------------------------'
    Rake::Task['madmpopidor:initialize_research_ouputs_uuid'].execute
    p '------------------------------------------------------------------------'
    p 'Upgrade complete'
  end

  desc 'Initialize research outputs UUID'
  task initialize_research_ouputs_uuid: :environment do
    p 'Creating research outputs UUID...'
    ResearchOutput.all.each(&:generate_uuid!)
    p 'Done.'
  end

  desc 'Initialize Dmp, Project, Meta & ResearchOutputs JSON fragments for the ancient plans'
  task initialize_plan_fragments: :environment do
    p 'Creating plans fragments...'
    Plan.includes(:contributors).each do |plan|
      FastGettext.with_locale plan.template.locale do
        plan.create_plan_fragments if plan.json_fragment.nil?

        dmp_fragment = plan.json_fragment
        dmp_fragment.persons.first.destroy if plan.owner.present?

        project_fragment = dmp_fragment.project
        meta_fragment = dmp_fragment.meta
        principal_investigator = project_fragment.principal_investigator
        data_contact = meta_fragment.contact
        plan.contributors.each do |contributor|
          identifier = contributor.identifiers.first
          person_data = {
            'nameType' => _('Personal'),
            'lastName' => contributor.name,
            'mbox' => contributor.email,
            'personId' => identifier&.value,
            'idType' => identifier.present? ? 'ORCID' : ''
          }

          person = MadmpFragment.fragment_exists?(
            person_data, MadmpSchema.find_by(name: 'PersonStandard'), dmp_fragment.id
          )
          if person.eql?(false)
            person = Fragment::Person.create(
              data: person_data,
              dmp_id: dmp_fragment.id,
              madmp_schema: MadmpSchema.find_by(name: 'PersonStandard'),
              additional_info: { property_name: 'person' }
            )
          end
          # if plan has one contributor, the person is attributed PI & DC roles
          if plan.contributors.length == 1
            data_contact.update(
              data: data_contact.data.merge(
                'person' => { 'dbid' => person.id }
              )
            )
            principal_investigator.update(
              data: principal_investigator.data.merge(
                'person' => { 'dbid' => person.id }
              )
            )
          elsif contributor.data_curation
            data_contact.update(
              data: data_contact.data.merge(
                'person' => { 'dbid' => person.id }
              )
            )
          else
            principal_investigator.update(
              data: principal_investigator.data.merge(
                'person' => { 'dbid' => person.id }
              )
            )
          end
        end

        #################################
        # PROJECT FUNDINGS
        #################################
        if plan.grant_number.present? || plan.funder_name.present?
          funding = Fragment::Funding.create(
            data: {
              'grantId' => plan.grant_number
            },
            dmp_id: dmp_fragment.id,
            parent_id: project_fragment.id,
            madmp_schema: MadmpSchema.find_by(name: 'FundingStandard'),
            additional_info: { property_name: 'funding' }
          )
          funding.instantiate
          funding.funder.update(
            additional_info: funding.funder.additional_info.merge(
              'custom_value' => plan.funder_name
            )
          )
        end

        plan.research_outputs.each do |research_output|
          next if research_output.nil? && research_output.json_fragment.present?

          research_output.create_json_fragments
          research_output_description = research_output.json_fragment.research_output_description
          ro_type = if research_output.other_type_label.present?
                      research_output.other_type_label
                    else
                      research_output.type.label
                    end

          research_output_description.update(
            data: research_output_description.data.merge(
              'type' => _(ro_type)
            )
          )
        end
      end
    end
    p 'Done.'
  end

  desc 'Add Structured question format in table'
  task add_structure_question_format: :environment do
    if QuestionFormat.find_by(title: 'Structured').nil?
      p 'Adding Structured question format...'
      QuestionFormat.create!(
        {
          title: 'Structured',
          description: 'Structured question format',
          option_based: false,
          formattype: 9,
          structured: true
        }
      )
      p 'Done.'
    end
  end

  desc 'Initialize the template locale to the default language of the application'
  task initialize_template_locale: :environment do
    p 'Updating template with default locale...'
    languages = Language.all
    Template.all.each do |template|
      if languages.find_by(abbreviation: template.locale).nil?
        template.update_columns(locale: Language.default.abbreviation)
      end
    end
    p 'Done'
  end

  desc 'Seeds the database with the madmp data'
  task seed: :environment do
    p 'Seeding database...'
    Rake::Task['madmpopidor:load_templates'].execute
    load(Rails.root.join('db', 'madmp_seeds.rb'))
  end

  # Load templates form an index file
  desc 'Load JSON templates for structured questions in the database'
  task load_templates: :environment do
    p 'Loading maDMP Templates...'
    # Read and parse index.json file
    index_path = Rails.root.join('config/madmp/schemas/main/index.json')
    schemas_index = JSON.parse(File.open(index_path))

    # Iterate over the schemas of the index.json file
    schemas_index.each do |schema_desc|
      # Read, parse and extract useful data from the JSON schema
      schema_path = Rails.root.join("config/madmp/schemas/main/#{schema_desc['path']}")
      json_schema = JSON.parse(File.read(schema_path))
      title = json_schema['title']
      classname = schema_desc['classname']

      begin
        schema = MadmpSchema.find_or_initialize_by(name: title) do |s|
          s.label = title
          s.name = title
          s.version = 1
          s.org_id = Org.first.id
          s.classname = classname
        end
        schema.update(schema: json_schema)
        p "#{schema.name} loaded"
      rescue ActiveRecord::RecordInvalid
        p "ERROR: template #{title} is invalid (model validations)"
      end
    end

    # Replace all 'template_name' key/values with 'schema_id' equivalent in loaded schemas
    MadmpSchema.all.each do |schema|
      p 'Substituting template_name...'
      schema.update(schema: MadmpSchema.substitute_names(schema.schema))
      p 'Done.'
    rescue ActiveRecord::RecordNotFound => e
      p "ERROR: template name substitution failed in #{schema.name}: #{e.message}"
      next
    end
    p 'maDMP Templates loaded.'
  end

  # Load registries
  desc 'Load JSON registries'
  task load_registries: :environment do
    p 'Loading maDMP registries...'
    registries_path = Rails.root.join('config/madmp/registries/index.json')
    registries = JSON.parse(File.open(registries_path))

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
      elsif values['path'].present?
        values_path = Rails.root.join("config/madmp/registries/#{values['path']}")
        registry_values = JSON.parse(File.open(values_path))
      end
      registry_values.each_with_index do |reg_val, idx|
        RegistryValue.create!(data: reg_val, registry: registry, order: idx)
      end
      p "#{registry_name} loaded."
    end
    p 'Done.'
  end
end
# rubocop:enable Naming/VariableNumber
