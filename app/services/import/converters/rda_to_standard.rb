# frozen_string_literal: true

module Import
  module Converters
    # Service used to convert plan from RDA DMP Commons Standars Format
    # to Standard Format
    class RdaToStandard
      class << self
        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def convert(json)
          return {} unless json.present?

          {
            'meta' => {
              'creationDate' => json['created'],
              'description' => json['description'],
              'dmpId' => json.dig('dmp_id', 'identifier'),
              'idType' => json.dig('dmp_id', 'type'),
              'dmpLanguage' => json['language'],
              'lastModifiedDate' => json['modified'],
              'title' => json['title'],
              'license' => {},
              'licenseStartDate' => '',
              'relatedDoc' => [],
              'associatedDmp' => [],
              'contact' => {
                'person' => {
                  'personId' => json.dig('contact', 'contact_id', 'identifier'),
                  'idType' => json.dig('contact', 'contact_id', 'type'),
                  'mbox' => json.dig('contact', 'mbox'),
                  'lastName' => json.dig('contact', 'name')
                }
              }
            },
            'project' => convert_project(json['project']),
            'budget' => { 'cost' => convert_cost(json['cost']) },
            'researchOutput' => convert_research_output(json['dataset'], json)
          }
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        def convert_project(projects)
          return {} if projects.nil?

          project = projects[0]
          {
            'description' => project['description'],
            'endDate' => project['end'],
            'funding' => convert_funding(project['funding']),
            'startDate' => project['start'],
            'title' => project['title']
          }
        end

        def convert_funding(fundings)
          return [] if fundings.nil?

          fundings_list = []
          fundings.each do |elem|
            fundings_list.append(
              {
                'funder' => {
                  'funderId' => elem.dig('funder_id', 'identifier'),
                  'idType' => elem.dig('funder_id', 'type')
                },
                'fundingStatus' => elem['funding_status'],
                'grantId' => elem.dig('grant_id', 'identifier')
              }
            )
          end
          fundings_list
        end

        # FROM
        # {
        #   "name": "DMP Administrator",
        #   "mbox": "info-opidor@inist.fr",
        #   "role": [
        #     "Coordinateur de projet",
        #     "Personne contact pour les données (Research Output 1, Research Output 2, Research Output 3)"
        #   ],
        #   "contributor_id": {
        #     "identifier": 1234,
        #     "type": "DOI"
        #   }
        # }
        # TO
        #
        # {
        #   "lastName": "DMP Administrator",
        #   "mbox": "info-opidor@inist.fr",
        #   "personId": 1234,
        #   "idType": "DOI"
        # }
        def convert_contributors(contributors)
          return [] if contributors.nil?

          contributors_list = []
          contributors.each do |contributor|
            contributors_list.append(
              {
                'lastName' => contributor['name'],
                'mbox' => contributor['mbox'],
                'personId' => contributor.dig('contributor_id', 'identifier'),
                'idType' => contributor.dig('contributor_id', 'type')

              }
            )
          end
          contributors_list
        end

        def convert_metadata(metadata)
          return [] if metadata.nil?

          metadata_list = []
          metadata.each do |elem|
            metadata_list.append(
              {
                'description' => elem['description'],
                'metadataLanguage' => elem['language'],
                'metadataStandardId' => elem.dig('metadata_standard_id', 'identifier'),
                'idType' => elem.dig('metadata_standard_id', 'type')
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
              'facility' => {
                'description' => elem['description'],
                'title' => elem['name']
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
                'currency' => elem['currency_code'],
                'costType' => elem['description'],
                'title' => elem['title'],
                'amount' => elem['value']
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
                'availability' => elem.dig('host', 'availability'),
                'certification' => elem.dig('host', 'certified_with'),
                'description' => elem.dig('host', 'description'),
                'geoLocation' => elem.dig('host', 'geo_location'),
                'pidSystem' => elem.dig('host', 'pid_system'),
                'hasVersioningPolicy' => elem.dig('host', 'support_versioning'),
                'title' => elem.dig('host', 'title'),
                'technicalRessourceId' => elem.dig('host', 'url')
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
                'releaseDate' => '',
                'accessUrl' => elem['access_url'],
                'availableUntil' => elem['available_until'],
                'fileVolume' => elem['byte_size'],
                'dataAccess' => elem['data_access'],
                'description' => elem['description'],
                'downloadUrl' => elem['download_url'],
                'fileFormat' => elem['format'],
                'fileName' => elem['title'],
                'license' => {
                  'licenseUrl' => elem.dig('license', 'license_ref')
                },
                'licenseStartDate' => elem.dig('license', 'start_date')
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
                'documentationQuality' => {
                  'description' => dataset['data_quality_assurance'],
                  'metadataStandard' => convert_metadata(dataset['metadata'])
                },
                'researchOutputDescription' => {
                  'datasetId' => dataset.dig('dataset_id', 'identifier'),
                  'idType' => dataset.dig('dataset_id', 'type'),
                  'description' => dataset['description'],
                  'uncontrolledKeywords' => [dataset['keyword']],
                  'language' => dataset['language'],
                  'containsPersonalData' => dataset['personal_data'],
                  'title' => dataset['title'],
                  'type' => dataset['type'],
                  'containsSensitiveData' => dataset['sensitive_data'],
                  'hasEthicalIssues' => full_dmp['ethical_issues_exist']
                },
                'sharing' => {
                  'distribution' => convert_distribution(dataset['distribution']),
                  'host' => convert_host(dataset['distribution'])
                },
                'preservationIssues' => {
                  'description' => dataset['preservation_statement']
                },
                'dataStorage' => {
                  'securityMeasures' => convert_security_measures(dataset['security_and_privacy'])
                },
                'ethicalIssues' => {
                  'description' => full_dmp['ethical_issues_description'],
                  'resourceReference' => [{
                    'docIdentifier' => full_dmp['ethical_issues_report']
                  }]
                },
                'dataCollection' => convert_technical_ressource(dataset['technical_ressource'])
              }
            )
          end
          # rubocop:enable Metrics/BlockLength
          ro_list
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
      end
    end
  end
end
