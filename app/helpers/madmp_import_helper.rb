# frozen_string_literal: true

# Help import data in the DMP
# rubocop:disable Metrics/ModuleLength
module MadmpImportHelper
  # rubocop:disable Metrics/AbcSize
  def import_dmp(plan, json_file, format)
    dmp_fragment = plan.json_fragment
    if json_file.respond_to?(:read)
      json_data = json_file.read
    elsif json_file.respond_to?(:path)
      json_data = File.read(json_file.path)
    else
      logger.error "Bad values_file: #{json_file.class.name}: #{json_file.inspect}"
    end

    begin
      dmp = JSON.parse(json_data)

      dmp = rda_to_default(dmp['dmp']).deep_stringify_keys if format.eql?('rda')

      dmp_fragment.raw_import(
        dmp.slice('meta', 'project', 'budget'), MadmpSchema.find_by(name: 'DMPStandard')
      )
      handle_research_outputs(plan, dmp['researchOutput'])
    rescue JSON::ParserError
      flash.now[:alert] = 'File should contain JSON'
    end
  end
  # rubocop:enable Metrics/AbcSize

  def handle_research_outputs(plan, research_outputs)
    research_outputs.each_with_index do |ro_data, idx|
      research_output = plan.research_outputs.create(
        abbreviation: "Research Output #{idx + 1}",
        title: ro_data['researchOutputDescription']['title'],
        is_default: idx.eql?(0),
        order: idx + 1
      )
      ro_frag = research_output.json_fragment
      import_research_output(ro_frag, ro_data, plan)
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def import_research_output(research_output_fragment, research_output_data, plan)
    dmp_id = research_output_fragment.dmp_id
    research_output_data.each do |prop, content|
      next if prop.eql?('research_output_id')

      schema_prop = research_output_fragment.madmp_schema.schema['properties'][prop]
      if research_output_fragment.data[prop].eql?(nil)
        # Fetch the associated question
        associated_question = plan.questions.joins(:madmp_schema).find_by(madmp_schema_id: schema_prop['schema_id'])
        next if associated_question.nil?

        fragment = MadmpFragment.new(
          dmp_id: dmp_id,
          parent_id: research_output_fragment.id,
          madmp_schema: associated_question.madmp_schema,
          additional_info: {
            'property_name' => prop
          }
        )
        fragment.classname = schema_prop['class']
        next unless associated_question.present? && @plan.template.structured?

        # Create a new answer for the question associated to the fragment
        fragment.answer = Answer.create(
          question_id: associated_question.id,
          research_output_id: research_output_fragment.research_output_id,
          plan_id: plan.id, user_id: plan.owner.id
        )
        fragment.save!
      else
        fragment = MadmpFragment.find(research_output_fragment.data[prop]['dbid'])
      end

      fragment.raw_import(content, fragment.madmp_schema, fragment.id)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def rda_to_default(rda_json)
    project = rda_json['project'][0]
    {
      meta: {
        creationDate: rda_json['created'],
        description: rda_json['description'],
        dmpId: rda_json.dig('dmp_id', 'identifier'),
        idType: rda_json.dig('dmp_id', 'type'),
        dmpLanguage: rda_json['language'],
        lastModifiedDate: rda_json['modified'],
        title: rda_json['title'],
        licence: '',
        licenceStartDate: '',
        relatedDoc: [],
        associatedDmp: [],
        contact: {
          person: {
            personId: rda_json.dig('contact', 'contact_id', 'identifier'),
            idType: rda_json.dig('contact', 'contact_id', 'type'),
            mbox: rda_json.dig('contact', 'mbox'),
            lastName: rda_json.dig('contact', 'name')
          }
        }
      },
      project: {
        description: project['description'],
        endDate: project['end'],
        funding: convert_funding(project['funding']),
        startDate: project['start'],
        title: project['title']
      },
      budget: { cost: convert_cost(rda_json['cost']) },
      researchOutput: convert_research_output(rda_json['dataset'], rda_json)
    }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def convert_funding(fundings)
    return [] if fundings.nil?

    fundings_list = []
    fundings.each do |elem|
      fundings_list.append(
        {
          funder: {
            funderId: elem.dig('funder_id', 'identifier'),
            idType: elem.dig('funder_id', 'type')
          },
          fundingStatus: elem['funding_status'],
          grantId: elem.dig('grant_id', 'identifier')
        }
      )
    end
    fundings_list
  end

  def convert_metadata(metadata)
    return [] if metadata.nil?

    metadata_list = []
    metadata.each do |elem|
      metadata_list.append(
        {
          description: elem['description'],
          metadataLanguage: elem['language'],
          metadataStandardId: elem.dig('metadata_standard_id', 'identifier'),
          idType: elem.dig('metadata_standard_id', 'type')
        }
      )
    end
    metadata_list
  end

  def convert_technical_ressource(facilities)
    return [] if facilities.nil?

    facilities_list = []
    facilities.each do |elem|
      facilities_list.append(
        facility: {
          description: elem['description'],
          title: elem['name']
        }
      )
    end
    facilities_list
  end

  def convert_cost(costs)
    return [] if costs.nil?

    costs_list = []
    costs.each do |elem|
      costs_list.append(
        {
          currency: elem['currency_code'],
          costType: elem['description'],
          title: elem['title'],
          amount: elem['value']
        }
      )
    end
    costs_list
  end

  def convert_host(distributions)
    return [] if distributions.nil?

    hosts_list = []
    distributions.each do |elem|
      hosts_list.append(
        {
          availability: elem.dig('host', 'availability'),
          certification: elem.dig('host', 'certified_with'),
          description: elem.dig('host', 'description'),
          geoLocation: elem.dig('host', 'geo_location'),
          pidSystem: elem.dig('host', 'pid_system'),
          hasVersioningPolicy: elem.dig('host', 'support_versioning'),
          title: elem.dig('host', 'title'),
          technicalRessourceId: elem.dig('host', 'url')
        }
      )
    end
    hosts_list
  end

  # rubocop:disable Metrics/MethodLength
  def convert_distribution(distribution)
    return [] if distribution.nil?

    distributions_list = []
    distribution.each do |elem|
      distributions_list.append(
        {
          releaseDate: '',
          accessUrl: elem.dig('distribution', 'access_url'),
          availableUntil: elem.dig('distribution', 'available_until'),
          fileVolume: elem.dig('distribution', 'byte_size'),
          dataAccess: elem.dig('distribution', 'data_access'),
          description: elem.dig('distribution', 'description'),
          downloadUrl: elem.dig('distribution', 'download_url'),
          fileFormat: elem.dig('distribution', 'format'),
          fileName: elem.dig('distribution', 'title'),
          licence: {
            licenceUrl: elem.dig('distribution', 'licence', 'licence_ref'),
            licenceStartDate: elem.dig('distribution', 'licence', 'start_date')
          }
        }
      )
    end
    distributions_list
  end
  # rubocop:enable Metrics/MethodLength

  def convert_security_measures(security_info)
    return '' if security_info.blank?

    title = security_info['title']
    description = security_info['description']

    return title.concat(':', description) unless title.nil? || description.nil?
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def convert_research_output(research_output, full_dmp)
    ro_list = []
    # rubocop:disable Metrics/BlockLength
    research_output.each do |dataset|
      ro_list.append(
        {
          documentationQuality: {
            description: dataset['data_quality_assurance'],
            metadataStandard: convert_metadata(dataset['metadata'])
          },
          researchOutputDescription: {
            datasetId: dataset.dig('dataset_id', 'identifier'),
            idType: dataset.dig('dataset_id', 'type'),
            description: dataset['description'],
            uncontrolled_keywords: [dataset['keyword']],
            language: dataset['language'],
            containsPersonalData: dataset['personal_data'],
            title: dataset['title'],
            type: dataset['type'],
            containsSensitiveData: dataset['sensitive_data'],
            hasEthicalIssues: full_dmp['ethical_issues_exist']

          },
          sharing: {
            distribution: convert_distribution(dataset['distribution']),
            host: convert_host(dataset['distribution'])
          },
          preservationIssues: {
            description: dataset['preservation_statement']

          },
          dataStorage: {
            securityMeasures: convert_security_measures(dataset['security_and_privacy'])

          },
          ethicalIssues: {
            description: full_dmp['ethical_issues_description'],
            ressourceReference: {
              docIdentifier: full_dmp['ethical_issues_report']
            }
          },
          dataCollection: convert_technical_ressource(dataset['technical_ressource'])

        }
      )
    end
    # rubocop:enable Metrics/BlockLength
    ro_list
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
# rubocop:enable Metrics/ModuleLength
