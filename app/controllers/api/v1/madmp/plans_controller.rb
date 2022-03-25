# frozen_string_literal: true

module Api
  module V1
    module Madmp
      # Handles CRUD operations for MadmpSchemas in API V1
      class PlansController < BaseApiController
        respond_to :json
        include MadmpExportHelper

        # GET /api/v1/madmp/plans/:id
        # rubocop:disable Metrics/AbcSize
        def show
          plan = Plan.find(params[:id])
          plan_fragment = plan.json_fragment
          selected_research_outputs = query_params[:research_outputs]&.map(&:to_i) || plan.research_output_ids
          # check if the user has permissions to use the API
          unless Api::V1::Madmp::PlansPolicy.new(client, plan).show?
            render_error(errors: 'Unauthorized to access plan', status: :unauthorized)
            return
          end

          respond_to do |format|
            format.json
            render 'shared/export/madmp_export_templates/default/plan', locals: {
              dmp: plan_fragment, selected_research_outputs: selected_research_outputs
            }
            return
          end
        rescue ActiveRecord::RecordNotFound
          render_error(errors: [_('Plan not found')], status: :not_found)
        end
        # rubocop:enable Metrics/AbcSize

        # GET /api/v1/madmp/plans/:id/rda_export
        # rubocop:disable Metrics/AbcSize
        def rda_export
          plan = Plan.find(params[:id])
          plan_fragment = plan.json_fragment
          selected_research_outputs = query_params[:research_outputs]&.map(&:to_i) || plan.research_output_ids
          # check if the user has permissions to use the API
          unless Api::V1::Madmp::PlansPolicy.new(client, plan).rda_export?
            render_error(errors: 'Unauthorized to access plan', status: :unauthorized)
            return
          end

          respond_to do |format|
            format.json
            render 'shared/export/madmp_export_templates/rda/plan', locals: {
              dmp: plan_fragment, selected_research_outputs: selected_research_outputs
            }
            return
          end
        rescue ActiveRecord::RecordNotFound
          render_error(errors: [_('Plan not found')], status: :not_found)
        end
        # rubocop:enable Metrics/AbcSize

        def rda_import
          rda_dmp = params["dmp"]
          @dmp = rda_to_madmp(rda_dmp)
          @dmp = @dmp.deep_stringify_keys
          # @dmp.dig("meta", "contact", "person", "mbox")
          @template = Template.default
          # Need to have an account already, admin mail meanwhile
          @plan_user = User.find_by(email: "info-opidor@inist.fr")
          p @plan_user
          # ensure user exists
          if @plan_user.blank?
            User.invite!({ email: params[:plan][:email] }, @user)
            @plan_user = User.find_by(email: params[:plan][:email])
            @plan_user.org = @user.org
            @plan_user.save
          end
          @plan = Plan.new
          @plan.principal_investigator = if @plan_user.surname.blank?
                                           nil
                                         else
                                           @plan_user.name(false)
                                         end

          @plan.data_contact = @plan_user.email
          # set funder name to template's org, or original template's org
          @plan.funder_name = if @template.customization_of.nil?
                                @template.org.name
                              else
                                Template.where(
                                  family_id: @template.customization_of
                                ).first.org.name
                              end
          @plan.template = @template
          @plan.title = params[:plan][:title]

          if @plan.save

            @plan.add_user!(@plan_user.id, :creator)

            
            @plan.create_plan_fragments
            @dmp_fragment = @plan.json_fragment
            @dmp_fragment.raw_import(@dmp.slice("meta", "project"), MadmpSchema.find_by(name: "DMPStandard"))

            research_outputs = @dmp["researchOutput"]
            research_outputs.each do |element|
              begin
                max_order = @plan.research_outputs.maximum("order") + 1
              rescue StandardError => e
                max_order = 1
              end
              @created_research_output = @plan.research_outputs.create(
                abbreviation: "Research Output #{max_order}",
                fullname: element["researchOutputDescription"]["title"],
                is_default: false,
                type: ResearchOutputType.find_by(label: "Dataset"),
                order: max_order
              )

              @research_output = @created_research_output.json_fragment
              fill_research_output(element, MadmpSchema.find_by(name: "ResearchOutputStandard"), @dmp_fragment.id, @research_output.id)
            end
            respond_with @plan
          else
            # the plan did not save
            headers["WWW-Authenticate"] = "Token realm=\"\""
            render json: _("Bad Parameters"), status: 400
          end
        end

        # POST /api/v1/madmp/plans/standard_import
        def standard_import
          @dmp = params
          p @dmp.keys
          @template = Template.default
          @plan_user = User.find_by(email: @dmp["meta"]["contact"]["person"]["mbox"])
          # ensure user exists
          if @plan_user.blank?
            #no plan in params
            User.invite!({ email: params[:plan][:email] }, @user)
            @plan_user = User.find_by(email: params[:plan][:email])
            @plan_user.org = @user.org
            @plan_user.save
          end
          @plan = Plan.new
          # add org (du créateur)
          @plan.org_id = @plan_user.org.id
          # p params
          # @plan.principal_investigator = if @plan_user.surname.blank?
          #                                  nil
          #                                else
          #                                  @plan_user.name(false)
          #                                end

          # @plan.data_contact = @plan_user.email
          # # set funder name to template's org, or original template's org
          # @plan.funder_name = if @template.customization_of.nil?
          #                       @template.org.name
          #                     else
          #                       Template.where(
          #                         family_id: @template.customization_of
          #                       ).first.org.name
          #                     end
          @plan.template_id = @template.id
          @plan.title = params[:meta][:title]
          if @plan.save

            @plan.add_user!(@plan_user.id, :creator)
            @plan.create_plan_fragments
            @dmp_fragment = @plan.json_fragment
            @dmp_fragment.raw_import(@dmp.slice("meta", "project"), MadmpSchema.find_by(name: "DMPStandard"))

            research_outputs = @dmp["researchOutput"]
            research_outputs.each do |element|
              begin
                max_order = @plan.research_outputs.maximum("order") + 1
              rescue StandardError => e
                max_order = 1
              end
              p ResearchOutputType.find_by(label: "Dataset").id
              p @created_research_output = @plan.research_outputs.create(
                abbreviation: "Research Output #{max_order}",
                title: element["researchOutputDescription"]["title"],
                is_default: false,
                research_output_type_id: ResearchOutputType.find_by(label: "Dataset").id,
                order: max_order
              )
              @research_output = @created_research_output.json_fragment
              fill_research_output(element, MadmpSchema.find_by(name: "ResearchOutputStandard"), @dmp_fragment.id, @research_output.id)
            end
            respond_with @plan
          else
            # the plan did not save
            headers["WWW-Authenticate"] = "Token realm=\"\""
            render json: _("Bad Parameters"), status: 400
          end
        end

        private

        def select_research_output(plan_fragment, _selected_research_outputs)
          plan_fragment.data['researchOutput'] = plan_fragment.data['researchOutput'].select do |r|
            r == { 'dbid' => research_output_id }
          end
          plan_fragment
        end

       

        private

        def fill_research_output(research_output_data, schema, dmp_id, parent_id)
          research_output_data.each do |prop, content|
            next if prop.eql?("research_output_id")
            schema_prop = schema.schema["properties"][prop]
            p 'schema'
            p schema
            if @research_output.data[prop].eql?(nil)
              # Fetch the associated question
              p associated_question = @plan.questions.joins(:madmp_schema).find_by(madmp_schema_id: schema_prop["schema_id"])
              p '-Fragment'
              fragment = MadmpFragment.new(
                dmp_id: dmp_id,
                parent_id: parent_id,
                madmp_schema: associated_question.madmp_schema,
                additional_info: {
                  "property_name" => prop
                }
              )
              fragment.classname = schema_prop["class"]
              p 'check here'
              p associated_question.present?
              p @plan.template
              next unless associated_question.present? && @plan.template.structured?

              # Create a new answer for the question associated to the fragment
              fragment.answer = Answer.create(
                question_id: associated_question.id,
                research_output_id: @created_research_output.id,
                plan_id: @plan.id,
                user_id: @plan_user.id
              )
              p 'ici'
              p fragment
              fragment.save!
            else
              fragment = MadmpFragment.find(@research_output.data[prop]["dbid"])
            end

            fragment.raw_import(content, fragment.madmp_schema, fragment.id)
            p 'import'
            p fragment
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
            budget: {
              cost: {
                currency:rda_json.dig('cost', 'currency_code'),
                costType:rda_json.dig('cost', 'description'),
                title:rda_json.dig('cost', 'title'),
                amount:rda_json.dig('cost', 'value'),
              },

            },
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

        def fill_distribution(distribution)
          if distribution.nil?
            return []
          end
          distributionsList = []
          distribution.each do |elem|
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
                                       distribution: [{
                                         releaseDate: dataset["issued"],
                                         accessUrl: dataset.dig("distribution", "access_url"),
                                         availableUntil: dataset.dig("distribution", "available_until"),
                                         fileVolume: dataset.dig("distribution", "byte_size"),
                                         dataAccess: dataset.dig("distribution", "data_access"),
                                         description: dataset.dig("distribution", "description"),
                                         downloadUrl: dataset.dig("distribution", "download_url"),
                                         fileFormat: dataset.dig("distribution", "format"),
                                         fileName: dataset.dig("distribution", "title"),
                                         licence: {
                                           licenceUrl: dataset.dig("distribution", "licence", "licence_ref"),
                                           licenceStartDate: dataset.dig("distribution", "licence", "start_date")
                                         }
                                       }],
                                       host: [{
                                         availability: dataset.dig("distribution", "host", "availability"),
                                         certification: dataset.dig("distribution", "host", "certified_with"),
                                         description: dataset.dig("distribution", "host", "description"),
                                         geoLocation: dataset.dig("distribution", "host", "geo_location"),
                                         pidSystem: dataset.dig("distribution", "host", "pid_system"),
                                         hasVersioningPolicy: dataset.dig("distribution", "host", "support_versioning"),
                                         title: dataset.dig("distribution", "host", "title"),
                                         technicalRessourceId: dataset.dig("distribution", "host", "url")
                                       }]
                                     },
                                     preservationIssues: {
                                       description: dataset["preservation_statement"]
        
                                     },
                                     dataStorage: {
                                       securityMeasures: dataset.dig("security_and_privacy", "description").concat(' : ', dataset.dig("security_and_privacy", "description")),
        
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
        

        def select_research_output(plan_fragment, _selected_research_outputs)
          plan_fragment.data["researchOutput"] = plan_fragment.data["researchOutput"].select do
            |r| r == { "dbid" => research_output_id }
          end
          plan_fragment
        end

        def query_params
          params.permit(:mode, research_outputs: [])
        end
      end
    end
  end
end
