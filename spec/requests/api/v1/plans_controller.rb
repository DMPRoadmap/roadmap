# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::PlansController, type: :request do

  include ApiHelper

  context "ApiClient" do

    before(:each) do
      mock_authorization_for_api_client

      # Org model requires a language so make sure the default is set
      create(:language, default_language: true)
    end

    describe "GET /api/v1/plan/:id - show" do
      it "returns the plan" do
        plan = create(:plan, api_client_id: ApiClient.first&.id)
        get api_v1_plan_path(plan)
        expect(response.code).to eql("200")
        expect(response).to render_template("api/v1/plans/index")
        expect(assigns(:items).length).to eql(1)
      end
      it "returns a 404 if the ApiClient did not create the plan" do
        plan = create(:plan, api_client_id: create(:api_client))
        get api_v1_plan_path(plan)
        expect(response.code).to eql("404")
        expect(response).to render_template("api/v1/error")
      end
      it "returns a 404 if not found" do
        get api_v1_plan_path(9999)
        expect(response.code).to eql("404")
        expect(response).to render_template("api/v1/error")
      end
    end

    describe "POST /api/v1/plans - create" do
      include Webmocks
      include Mocks::ApiJsonSamples

      before(:each) do
        stub_ror_service
        mock_identifier_schemes
        create(:template, :publicly_visible, is_default: true, published: true)
      end

      context "minimal JSON" do
        before(:each) do
          @json = JSON.parse(minimal_create_json).with_indifferent_access
        end

        it "returns a 400 if the incoming JSON is invalid" do
          post api_v1_plans_path, Faker::Lorem.word
          expect(response.code).to eql("400")
          expect(response).to render_template("api/v1/error")
        end
        it "returns a 400 if the incoming DMP is invalid" do
          create(:plan, api_client_id: ApiClient.first.id)
          @json[:items].first[:dmp][:title] = ""
          post api_v1_plans_path, @json.to_json
          expect(response.code).to eql("400")
          expect(response).to render_template("api/v1/error")
        end
        it "returns a 400 if the plan already exists" do
          plan = create(:plan, created_at: (Time.now - 3.days),
                               api_client_id: ApiClient.first.id)
          @json[:items].first[:dmp][:dmp_id] = {
            type: "url",
            identifier: Rails.application.routes.url_helpers.api_v1_plan_url(plan)
          }
          post api_v1_plans_path, @json.to_json
          expect(response.code).to eql("400")
          expect(response).to render_template("api/v1/error")
          expect(response.body.include?("already exists")).to eql(true)
        end
        it "returns a 201 if the incoming JSON is valid" do
          post api_v1_plans_path, @json.to_json
          expect(response.code).to eql("201")
          expect(response).to render_template("api/v1/plans/index")
        end

        context "plan inspection" do
          before(:each) do
            post api_v1_plans_path, @json.to_json
            @original = @json.with_indifferent_access[:items].first[:dmp]
            @plan = Plan.last
          end

          it "set the Plan title" do
            expect(@plan.title).to eql(@original[:title])
          end
          it "attached the contact to the Plan" do
            expect(@plan.contributors.length).to eql(1)
          end
          it "set the Contact email" do
            expected = @plan.contributors.first.email
            expect(expected).to eql(@original[:contact][:mbox])
          end
          it "attached the plan to the API Client's Org" do
            expect(@plan.org).to eql(ApiClient.first.org)
          end
          it "set the Contact roles" do
            expected = @plan.contributors.first
            expect(expected.data_curation?).to eql(true)
          end
          it "set the Template id" do
            app = ApplicationService.application_name.split("-").first
            tmplt = @original[:extension].select { |i| i[app].present? }.first
            expected = tmplt[app][:template][:id]
            expect(@plan.template_id).to eql(expected)
          end
        end
      end

      context "complete JSON" do
        before(:each) do
          @json = JSON.parse(complete_create_json).with_indifferent_access
        end

        it "returns a 201 if the incoming JSON is valid" do
          post api_v1_plans_path, @json.to_json
          expect(response.code).to eql("201")
          expect(response).to render_template("api/v1/plans/index")
        end

        context "plan inspection" do
          before(:each) do
            post api_v1_plans_path, @json.to_json
            @original = @json.with_indifferent_access[:items].first[:dmp]
            @plan = Plan.last
          end

          it "set the Plan title" do
            expect(@plan.title).to eql(@original[:title])
          end

          it "set the Plan description" do
            expect(@plan.title).to eql(@original[:title])
          end
          it "set the Plan start_date" do
            expect(@plan.title).to eql(@original[:title])
          end
          it "set the Plan end_date" do
            expect(@plan.title).to eql(@original[:title])
          end
          it "Plan identifiers includes the grant id" do
            expect(@plan.identifiers.length).to eql(1)
            expected = @original[:project].first[:funding].first[:grant_id][:type]
            expect("other").to eql(expected)

            expected = @original[:project].first[:funding].first[:grant_id][:identifier]
            expect(@plan.identifiers.first.value).to eql(expected)
          end

          context "contact inspection" do
            before(:each) do
              @original = @original[:contact]
              contacts = @plan.contributors.select do |pc|
                pc.email == @original[:mbox]
              end
              @contact = contacts.first
            end

            it "attached the Contact to the Plan" do
              expect(@contact.present?).to eql(true)
            end
            it "set the Contact name" do
              expect(@contact.name).to eql(@original[:name])
            end
            it "set the Contact email" do
              expect(@contact.email).to eql(@original[:mbox])
            end
            it "set the Contact roles" do
              expect(@contact.data_curation?).to eql(true)
            end
            it "Contact identifiers includes the orcid" do
              expect(@contact.identifiers.length).to eql(1)
              expected = @original[:contact_id][:type]
              expect(@contact.identifiers.first.identifier_scheme.name).to eql(expected)

              expected = @original[:contact_id][:identifier]
              rslt = @contact.identifiers.first.value
              expect(rslt.ends_with?(expected)).to eql(true)
            end
            it "ignored the unknown identifier type" do
              results = @contact.identifiers.select do |i|
                i.value == @original[:contact_id]
              end
              expect(results.any?).to eql(false)
            end

            context "contact org inspection" do
              before(:each) do
                @original = @original[:affiliation]
              end

              it "attached the Org to the Contact" do
                expect(@contact.org.present?).to eql(true)
              end
              it "sets the name" do
                expect(@contact.org.name).to eql(@original[:name])
              end
              it "sets the abbreviation" do
                expect(@contact.org.abbreviation).to eql(@original[:abbreviation])
              end
              it "Org identifiers includes the affiation id" do
                expect(@contact.org.identifiers.length).to eql(1)
                expected = @original[:affiliation_id][:type]
                result = @contact.org.identifiers.first.identifier_scheme.name
                expect(result).to eql(expected)

                expected = @original[:affiliation_id][:identifier]
                rslt = @contact.org.identifiers.first.value
                expect(rslt.ends_with?(expected)).to eql(true)
              end
              it "is the same as the Plan's org" do
                expect(@plan.org).to eql(@contact.org)
              end
            end
          end

          context "contributor inspection" do
            before(:each) do
              @original = @original[:contributor].first
              contributors = @plan.contributors.select do |contrib|
                contrib.email == @original[:mbox]
              end
              @subject = contributors.first
            end

            it "attached the Contributor to the Plan" do
              expect(@subject.present?).to eql(true)
            end
            it "set the Contributor name" do
              expect(@subject.name).to eql(@original[:name])
            end
            it "set the Contributor email" do
              expect(@subject.email).to eql(@original[:mbox])
            end
            it "set the Contributor roles" do
              expected = @original[:role].map do |role|
                role.gsub("#{Contributor::ONTOLOGY_BASE_URL}/", "")
              end
              expect(@subject.send(:"#{expected.first.downcase}?")).to eql(true)
            end
            it "Contributor identifiers includes the orcid" do
              expect(@subject.identifiers.length).to eql(1)
              expected = @original[:contributor_id][:type]
              expect(@subject.identifiers.first.identifier_scheme.name).to eql(expected)

              expected = @original[:contributor_id][:identifier]
              rslt = @subject.identifiers.first.value
              expect(rslt.ends_with?(expected)).to eql(true)
            end

            context "contributor org inspection" do
              before(:each) do
                @original = @original[:affiliation]
              end

              it "attached the Org to the Contributor" do
                expect(@subject.org.present?).to eql(true)
              end
              it "sets the name" do
                expect(@subject.org.name).to eql(@original[:name])
              end
              it "sets the abbreviation" do
                expect(@subject.org.abbreviation).to eql(@original[:abbreviation])
              end
              it "Org identifiers includes the affiation id" do
                expect(@subject.org.identifiers.length).to eql(1)
                expected = @original[:affiliation_id][:type]
                expect("ror").to eql(expected)

                expected = @original[:affiliation_id][:identifier]
                rslt = @subject.org.identifiers.first.value
                expect(rslt.ends_with?(expected)).to eql(true)
              end
            end
          end

          context "funder inspection" do
            before(:each) do
              @original = @original[:project].first[:funding].first
              @funder = @plan.funder
            end

            it "attached the Funder to the Plan" do
              expect(@funder.present?).to eql(true)
            end
            it "sets the name" do
              expect(@funder.name).to eql(@original[:name])
            end
            it "Funder identifiers includes the funder_id id" do
              expect(@funder.identifiers.length).to eql(1)
              expected = @original[:funder_id][:type]
              expect(@funder.identifiers.first.identifier_scheme.name).to eql(expected)

              expected = @original[:funder_id][:identifier].to_s
              rslt = @funder.identifiers.first.value
              expect(rslt.ends_with?(expected)).to eql(true)
            end
          end

          it "set the Template id" do
            app = ApplicationService.application_name.split("-").first
            tmplt = @original[:extension].select { |i| i[app].present? }.first
            expected = tmplt[app][:template][:id]
            expect(@plan.template_id).to eql(expected)
          end
        end

      end

    end
  end

  context "User" do

    before(:each) do
      mock_authorization_for_user
    end

    describe "GET /api/v1/plan/:id - show" do
      it "returns the plan" do
        plan = create(:plan, :creator, :organisationally_visible, org: Org.last)
        get api_v1_plan_path(plan)
        expect(response.code).to eql("200")
        expect(response).to render_template("api/v1/plans/index")
        expect(assigns(:items).length).to eql(1)
      end
      it "returns a 404 if not found" do
        get api_v1_plan_path(9999)
        expect(response.code).to eql("404")
        expect(response).to render_template("api/v1/error")
      end
      it "returns a 404 if the user does not have access" do
        org2 = create(:org)
        plan = create(:plan, :creator, :organisationally_visible, org: org2)
        get api_v1_plan_path(plan)
        expect(response.code).to eql("404")
        expect(response).to render_template("api/v1/error")
      end
    end

  end

end
