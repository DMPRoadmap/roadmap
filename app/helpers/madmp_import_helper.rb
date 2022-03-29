# frozen_string_literal: true

# Help import data in the DMP
# rubocop:disable Metrics/ModuleLength
module MadmpImportHelper
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def fill_research_output(research_output_data, schema, dmp_id, parent_id)
    research_output_data.each do |prop, content|
      next if prop.eql?('research_output_id')

      schema_prop = schema.schema['properties'][prop]
      if @research_output.data[prop].eql?(nil)
        # Fetch the associated question
        associated_question = @plan.questions.joins(:madmp_schema).find_by(madmp_schema_id: schema_prop['schema_id'])
        fragment = MadmpFragment.new(
          dmp_id: dmp_id,
          parent_id: parent_id,
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
          research_output_id: @created_research_output.id,
          plan_id: @plan.id,
          user_id: @plan_user.id
        )

        fragment.save!
      else
        fragment = MadmpFragment.find(@research_output.data[prop]['dbid'])
      end

      fragment.raw_import(content, fragment.madmp_schema, fragment.id)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def rda_to_madmp(rda_json)
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
        description: rda_json.dig('project', 'description'),
        endDate: rda_json.dig('project', 'end'),
        funding: fill_funding(rda_json.dig('project', 'funding')),
        startDate: rda_json.dig('project', 'start'),
        title: rda_json.dig('project', 'title')
      },
      budget: fill_cost(rda_json['cost']),
      researchOutput: rda_to_madmp_research_output(rda_json['dataset'], rda_json)
    }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def fill_funding(fundings)
    return [] if funders.nil?

    fundings_list = []
    fundings.each do |elem|
      funders_list.append(
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

  def fill_metadata(metadata)
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

  def fill_technical_ressource(facilities)
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

  def fill_cost(costs)
    return [] if costs.nil?

    costs_list = []
    costs.each do |elem|
      costs_list.append(
        cost: {
          currency: elem.dig('cost', 'currency_code'),
          costType: elem.dig('cost', 'description'),
          title: elem.dig('cost', 'title'),
          amount: elem.dig('cost', 'value')
        }
      )
    end
    costs_list
  end

  def fill_host(distributions)
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
  def fill_distribution(distribution)
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

  def fill_security_measures(security_info)
    return '' if security_info.nil?

    title = security_info['title']
    description = security_info['description']

    return title.concat(':', description) unless title.nil? || description.nil?
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def rda_to_madmp_research_output(research_output, full_dmp)
    ro_list = []
    # rubocop:disable Metrics/BlockLength
    research_output.each do |dataset|
      ro_list.append(
        {
          documentationQuality: {
            description: dataset['data_quality_assurance'],
            metadataStandard: fill_metadata(dataset['metadata'])
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
            distribution: fill_distribution(dataset['distribution']),
            host: fill_host(dataset['distribution'])
          },
          preservationIssues: {
            description: dataset['preservation_statement']

          },
          dataStorage: {
            securityMeasures: fill_security_measures(dataset['security_and_privacy'])

          },
          ethicalIssues: {
            description: full_dmp['ethical_issues_description'],
            ressourceReference: {
              docIdentifier: full_dmp['ethical_issues_report']
            }
          },
          dataCollection: fill_technical_ressource(dataset['technical_ressource'])

        }
      )
    end
    # rubocop:enable Metrics/BlockLength
    ro_list
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
# rubocop:enable Metrics/ModuleLength
