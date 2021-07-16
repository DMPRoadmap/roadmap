# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::PlansController, type: :request do

  include ApiHelper

  context "Non-Oauth (client_credentials grant type)" do

    before(:each) do
      @client = create(:api_client, trusted: false, user: create(:user, :org_admin, org: create(:org)))
      token = mock_client_credentials_token(api_client: @client)

      @headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer #{token.to_s}"
      }
      # Org model requires a language so make sure the default is set
      create(:language, default_language: true) unless Language.default.present?
    end

    describe "GET /api/v2/plans (index)" do
      it "returns 401 if the token is invalid" do
        @headers["Authorization"] = "Bearer #{SecureRandom.uuid}"
        get(api_v2_plans_path, headers: @headers)

        expect(response.code).to eql("401")
        expect(response).to render_template("api/v2/_standard_response")
        expect(response).to render_template("api/v2/error")

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:items].empty?).to eql(true)
        expect(json[:errors].length).to eql(1)
        expect(json[:errors].first).to eql("token is invalid, expired or has been revoked")
      end
      it "returns an empty array if no templates are available" do
        get(api_v2_plans_path, headers: @headers)

        expect(response.code).to eql("200")
        expect(response).to render_template("api/v2/_standard_response")
        expect(response).to render_template("api/v2/plans/index")

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:items].empty?).to eql(true)
        expect(json[:errors].nil?).to eql(true)
      end

      describe "returns expected plans" do
        before(:each) do
          @other_org_public = create(:plan, :publicly_visible, org: create(:org))
          @other_org_private = create(:plan, :privately_visible, org: create(:org))
          @other_org_organizational = create(:plan, :organisationally_visible, org: create(:org))
          @other_org_test = create(:plan, :is_test, org: create(:org))

          @my_org_public = create(:plan, :publicly_visible, org: @client.user.org)
          @my_org_private = create(:plan, :privately_visible, org: @client.user.org)
          @my_org_organizational = create(:plan, :organisationally_visible, org: @client.user.org)
          @my_org_test = create(:plan, :is_test, org: @client.user.org)
        end

        it "when the ApiClient is 'trusted'" do
          @client.update(trusted: true)
          ids = [
            api_v2_plan_url(@other_org_public),
            api_v2_plan_url(@other_org_private),
            api_v2_plan_url(@other_org_organizational),
            api_v2_plan_url(@my_org_private),
            api_v2_plan_url(@my_org_public),
            api_v2_plan_url(@my_org_organizational)
          ]
          get(api_v2_plans_path, headers: @headers)

          json = JSON.parse(response.body).with_indifferent_access
          expect(json[:items].length).to eql(6)
          json[:items].each do |item|
            expect(ids.include?(item[:dmp][:dmp_id][:identifier])).to eql(true)
          end
        end

        it "with params { 'scope': 'mine' }" do
          ids = [
            api_v2_plan_url(@my_org_private),
            api_v2_plan_url(@my_org_public),
            api_v2_plan_url(@my_org_organizational)
          ]
          get(api_v2_plans_path(scope: "mine"), headers: @headers)

          json = JSON.parse(response.body).with_indifferent_access
          expect(json[:items].length).to eql(3)
          json[:items].each do |item|
            expect(ids.include?(item[:dmp][:dmp_id][:identifier])).to eql(true)
          end
        end

        it "with params { 'scope': 'public' }" do
          ids = [
            api_v2_plan_url(@other_org_public),
            api_v2_plan_url(@my_org_public)
          ]
          get(api_v2_plans_path(scope: "public"), headers: @headers)

          json = JSON.parse(response.body).with_indifferent_access
          expect(json[:items].length).to eql(2)
          json[:items].each do |item|
            expect(ids.include?(item[:dmp][:dmp_id][:identifier])).to eql(true)
          end
        end

        it "with params { 'scope': 'both' }" do
          ids = [
            api_v2_plan_url(@other_org_public),
            api_v2_plan_url(@my_org_private),
            api_v2_plan_url(@my_org_public),
            api_v2_plan_url(@my_org_organizational)
          ]
          get(api_v2_plans_path(scope: "both"), headers: @headers)

          json = JSON.parse(response.body).with_indifferent_access
          expect(json[:items].length).to eql(4)
          json[:items].each do |item|
            expect(ids.include?(item[:dmp][:dmp_id][:identifier])).to eql(true)
          end
        end

        it "defaults to { scope: 'mine' }" do
          ids = [
            api_v2_plan_url(@my_org_private),
            api_v2_plan_url(@my_org_public),
            api_v2_plan_url(@my_org_organizational)
          ]
          get(api_v2_plans_path, headers: @headers)

          json = JSON.parse(response.body).with_indifferent_access
          expect(json[:items].length).to eql(3)
          json[:items].each do |item|
            expect(ids.include?(item[:dmp][:dmp_id][:identifier])).to eql(true)
          end
        end
      end

      it "allows for paging" do
        21.times { create(:plan, :publicly_visible) }
        get(api_v2_plans_path(scope: "public"), headers: @headers)

        test_paging(json: JSON.parse(response.body), headers: @headers)
      end
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
          post api_v1_plans_path, params: Faker::Lorem.word
          expect(response.code).to eql("400")
          expect(response).to render_template("api/v1/error")
        end
        it "returns a 400 if the incoming DMP is invalid" do
          create(:plan, api_client_id: ApiClient.first.id)
          @json[:items].first[:dmp][:title] = ""
          post api_v1_plans_path, params: @json.to_json
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
          post api_v1_plans_path, params: @json.to_json
          expect(response.code).to eql("400")
          expect(response).to render_template("api/v1/error")
          expect(response.body.include?("already exists")).to eql(true)
        end
        it "returns a 400 if the owner could not be determined" do
          @json[:items].first[:dmp][:contact].delete(:affiliation)
          post api_v1_plans_path, params: @json.to_json
          expect(response.code).to eql("400")
          expect(response.body.include?("Could not determine ownership")).to eql(true)
        end
        it "returns a 201 if the incoming JSON is valid" do
          post api_v1_plans_path, params: @json.to_json
          expect(response.code).to eql("201")
          expect(response).to render_template("api/v1/plans/index")
        end

        it "defaults to api_client.org when no Contact affiliation defined" do
          @client = ApiClient.first
          @client.update(org: create(:org))
          @client.reload
          mock_authorization_for_api_client

          @json[:items].first[:dmp][:contact].delete(:affiliation)
          post api_v1_plans_path, params: @json.to_json

          expect(response.code).to eql("201")
          expect(response).to render_template("api/v1/plans/index")
          @plan = Plan.last
          expect(@plan.org).to eql(@client.org)
        end

        context "plan inspection" do
          before(:each) do
            post api_v1_plans_path, params: @json.to_json
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
          it "attached the plan to the Contact's Org" do
            expect(@plan.org.name).to eql(@original[:contact][:affiliation][:name])
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
          post api_v1_plans_path, params: @json.to_json
          expect(response.code).to eql("201")
          expect(response).to render_template("api/v1/plans/index")
        end

        context "plan inspection" do
          before(:each) do
            post api_v1_plans_path, params: @json.to_json
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

end
