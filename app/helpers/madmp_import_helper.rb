# frozen_string_literal: true

# Help import data in the DMP
module MadmpImportHelper
    def fill_research_output(research_output_data, schema, dmp_id, parent_id)
        research_output_data.each do |prop, content|
          next if prop.eql?("research_output_id")
          schema_prop = schema.schema["properties"][prop]
          if @research_output.data[prop].eql?(nil)
            # Fetch the associated question
            associated_question = @plan.questions.joins(:madmp_schema).find_by(madmp_schema_id: schema_prop["schema_id"])
            fragment = MadmpFragment.new(
              dmp_id: dmp_id,
              parent_id: parent_id,
              madmp_schema: associated_question.madmp_schema,
              additional_info: {
                "property_name" => prop
              }
            )
            fragment.classname = schema_prop["class"]
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
            fragment = MadmpFragment.find(@research_output.data[prop]["dbid"])
          end

          fragment.raw_import(content, fragment.madmp_schema, fragment.id)
        end
      end

      def rda_to_madmp(rda_json)
        dmp = { 
          meta: {
            creationDate: rda_json["created"],
            description: rda_json["description"],
            dmpId: rda_json.dig("dmp_id", "identifier"),
            idType: rda_json.dig("dmp_id", "type"),
            dmpLanguage: rda_json["language"],
            lastModifiedDate: rda_json["modified"],
            title: rda_json["title"],
            licence: "",
            licenceStartDate: "",
            relatedDoc: [],
            associatedDmp: [],
            contact: {
              person: {
                personId: rda_json.dig("contact", "contact_id", "identifier"),
                idType: rda_json.dig("contact", "contact_id", "type"),
                mbox: rda_json.dig("contact", "mbox"),
                lastName: rda_json.dig("contact", "name")
              }
            }
          },
          project: {
            description: rda_json.dig("project", "description"),
            endDate: rda_json.dig("project", "end"),
            funding: fill_funding(rda_json.dig("project", "funding")),
            startDate: rda_json.dig("project", "start"),
            title: rda_json.dig("project", "title")
          },
          budget: fill_cost(rda_json.dig('cost')),
          researchOutput: rda_to_madmp_research_output(rda_json["dataset"], rda_json)
        }
        return dmp
      end

      def fill_funding(funders)
        if funders.nil?
          return []
        end
        fundersList = []
        funders.each do |elem|
          fundersList.append(
            {
            funder: {
              funderId: elem.dig("funder_id", "identifier"),
              idType: elem.dig("funder_id", "type")
            },
            fundingStatus: elem.dig("funding_status"),
            grantId: elem.dig("grant_id", "identifier"),
          }

          )
        end
        return fundersList
      end

      def fill_metadata(metadata)
        if metadata.nil?
          return []
        end
        metadataList = []
        metadata.each do |elem|
          metadataList.append(
            {
              description: elem["description"],
              metadataLanguage: elem["language"],
              metadataStandardId: elem.dig("metadata_standard_id", "identifier"),
              idType: elem.dig("metadata_standard_id", "type")
            }
          )
        end
        return metadataList
      end

      def fill_technical_ressource(facilities)
        if facilities.nil?
          return []
        end
        facilitiesList = []
        facilities.each do |elem|
          facilitiesList.append(
            facility: {
              description: dataset["description"],
              title: dataset["name"]
            }
          )
        end
        return facilitiesList
      end

      def fill_cost(costs)
        if costs.nil?
          return []
        end
        costsList = []
        costs.each do |elem|
          costsList.append(
            cost: {
              currency:elem.dig('cost', 'currency_code'),
              costType:elem.dig('cost', 'description'),
              title:elem.dig('cost', 'title'),
              amount:elem.dig('cost', 'value'),
            }
          )
        end
        return costsList
      end

      def fill_host(distributions)
        if distributions.nil?
          return []
        end

        hostsList = []
        distributions.each do |elem|
          hostsList.append(
            {
              availability: elem.dig("host", "availability"),
              certification: elem.dig("host", "certified_with"),
              description: elem.dig("host", "description"),
              geoLocation: elem.dig("host", "geo_location"),
              pidSystem: elem.dig("host", "pid_system"),
              hasVersioningPolicy: elem.dig("host", "support_versioning"),
              title: elem.dig("host", "title"),
              technicalRessourceId: elem.dig("host", "url")
            }
          )
        end
        return hostsList
      end

      def fill_distribution(distribution)
        if distribution.nil?
          return []
        end
        distributionsList = []
        distribution.each do |elem|
          distributionsList.append(
            {
              releaseDate: "",
              accessUrl: elem.dig("distribution", "access_url"),
              availableUntil: elem.dig("distribution", "available_until"),
              fileVolume: elem.dig("distribution", "byte_size"),
              dataAccess: elem.dig("distribution", "data_access"),
              description: elem.dig("distribution", "description"),
              downloadUrl: elem.dig("distribution", "download_url"),
              fileFormat: elem.dig("distribution", "format"),
              fileName: elem.dig("distribution", "title"),
              licence: {
                licenceUrl: elem.dig("distribution", "licence", "licence_ref"),
                licenceStartDate: elem.dig("distribution", "licence", "start_date")
              }
            }
          )
        end
      end

      def fill_security_measures(security_info)
        if security_info.nil?
          return ""
        end
        title = security_info.dig("title")
        description = security_info.dig("description")
        unless title.nil? or description.nil?
          return title.concat(':', description)
        end
      end

      def rda_to_madmp_research_output(research_output, full_DMP)
        researchOutputs = []
        research_output.each do |dataset|
          researchOutputs.append({
                                   documentationQuality: {
                                     description: dataset["data_quality_assurance"],
                                     metadataStandard: fill_metadata(dataset["metadata"])
                                   },
                                   researchOutputDescription: {
                                     datasetId: dataset.dig("dataset_id", "identifier"),
                                     idType: dataset.dig("dataset_id", "type"),
                                     description: dataset["description"],
                                     uncontrolled_keywords: [dataset["keyword"]],
                                     language: dataset["language"],
                                     containsPersonalData: dataset["personal_data"],
                                     title: dataset["title"],
                                     type: dataset["type"],
                                     containsSensitiveData: dataset["sensitive_data"],
                                     hasEthicalIssues: full_DMP["ethical_issues_exist"],
      
                                   },
                                   sharing: {
                                     distribution: fill_distribution(dataset["distribution"]),
                                     host: fill_host(dataset.dig("distribution"))
                                   },
                                   preservationIssues: {
                                     description: dataset["preservation_statement"]
      
                                   },
                                   dataStorage: {
                                     securityMeasures: fill_security_measures(dataset['security_and_privacy'])
      
                                   },
                                   ethicalIssues: {
                                     description: full_DMP['ethical_issues_description'],
                                     ressourceReference: {
                                       docIdentifier: full_DMP['ethical_issues_report']
                                     }
                                   },
                                   dataCollection: fill_technical_ressource(dataset["technical_ressource"])
      
                                 })
        end
        return researchOutputs
      end

end
