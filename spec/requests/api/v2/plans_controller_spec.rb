# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::PlansController do
  include Helpers::ApiHelper
  include Mocks::ApiV2JsonSamples
  include Helpers::Webmocks
  include Helpers::IdentifierHelper

  context 'Non-Oauth (client_credentials grant type)' do
    before do
      @client = create(:api_client, trusted: false, user: create(:user, :org_admin, org: create(:org)))
      token = mock_client_credentials_token(api_client: @client)

      @headers = {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        Authorization: "Bearer #{token}"
      }
      # Org model requires a language so make sure the default is set
      create(:language, default_language: true) if Language.default.blank?
    end

    describe 'GET /api/v2/plans (index)' do
      it 'returns 401 if the token is invalid' do
        @headers['Authorization'] = "Bearer #{SecureRandom.uuid}"
        get(api_v2_plans_path, headers: @headers)

        expect(response.code).to eql('401')
        expect(response).to render_template('api/v2/_standard_response')
        expect(response).to render_template('api/v2/error')

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:items].empty?).to be(true)
        expect(json[:errors].length).to be(1)
        expect(json[:errors].first).to eql('token is invalid, expired or has been revoked')
      end

      it 'returns an empty array if no plans are available' do
        get(api_v2_plans_path, headers: @headers)

        expect(response.code).to eql('404')
        expect(response).to render_template('api/v2/_standard_response')
        expect(response).to render_template('api/v2/error')

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:items].empty?).to be(true)
        expect(json[:errors].length).to be(1)
        expect(json[:errors].first).to eql('No Plans found')
      end

      describe 'returns expected plans' do
        before do
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
          expect(json[:items].length).to be(6)
          json[:items].each do |item|
            expect(ids.include?(item[:dmp][:dmp_id][:identifier])).to be(true)
          end
        end

        it "with params { 'scope': 'mine' }" do
          ids = [
            api_v2_plan_url(@my_org_private),
            api_v2_plan_url(@my_org_public),
            api_v2_plan_url(@my_org_organizational)
          ]
          get(api_v2_plans_path(scope: 'mine'), headers: @headers)

          json = JSON.parse(response.body).with_indifferent_access
          expect(json[:items].length).to be(3)
          json[:items].each do |item|
            expect(ids.include?(item[:dmp][:dmp_id][:identifier])).to be(true)
          end
        end

        it "with params { 'scope': 'public' }" do
          ids = [
            api_v2_plan_url(@other_org_public),
            api_v2_plan_url(@my_org_public)
          ]
          get(api_v2_plans_path(scope: 'public'), headers: @headers)

          json = JSON.parse(response.body).with_indifferent_access
          expect(json[:items].length).to be(2)
          json[:items].each do |item|
            expect(ids.include?(item[:dmp][:dmp_id][:identifier])).to be(true)
          end
        end

        it "with params { 'scope': 'both' }" do
          ids = [
            api_v2_plan_url(@other_org_public),
            api_v2_plan_url(@my_org_private),
            api_v2_plan_url(@my_org_public),
            api_v2_plan_url(@my_org_organizational)
          ]
          get(api_v2_plans_path(scope: 'both'), headers: @headers)

          json = JSON.parse(response.body).with_indifferent_access
          expect(json[:items].length).to be(4)
          json[:items].each do |item|
            expect(ids.include?(item[:dmp][:dmp_id][:identifier])).to be(true)
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
          expect(json[:items].length).to be(3)
          json[:items].each do |item|
            expect(ids.include?(item[:dmp][:dmp_id][:identifier])).to be(true)
          end
        end
      end

      it 'allows for paging' do
        create_list(:plan, 21, :publicly_visible)
        get(api_v2_plans_path(scope: 'public'), headers: @headers)

        test_paging(json: JSON.parse(response.body), headers: @headers)
      end
    end

    describe 'GET /api/v1/plan/:id - (show)' do
      it 'returns 401 if the token is invalid' do
        plan = create(:plan, :publicly_visible)
        @headers['Authorization'] = "Bearer #{SecureRandom.uuid}"
        get(api_v2_plan_path(plan), headers: @headers)

        expect(response.code).to eql('401')
        expect(response).to render_template('api/v2/_standard_response')
        expect(response).to render_template('api/v2/error')

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:items].empty?).to be(true)
        expect(json[:errors].length).to be(1)
        expect(json[:errors].first).to eql('token is invalid, expired or has been revoked')
      end

      it 'returns an empty array if no plans are available' do
        get(api_v2_plan_path(99_999), headers: @headers)

        expect(response.code).to eql('404')
        expect(response).to render_template('api/v2/_standard_response')
        expect(response).to render_template('api/v2/error')

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:items].empty?).to be(true)
        expect(json[:errors].length).to be(1)
        expect(json[:errors].first).to eql('Plan not found')
      end

      describe 'returns expected plan' do
        before do
          @other_org_public = create(:plan, :publicly_visible, org: create(:org))
          @other_org_private = create(:plan, :privately_visible, org: create(:org))
          @other_org_organizational = create(:plan, :organisationally_visible, org: create(:org))
          @other_org_test = create(:plan, :is_test, org: create(:org))

          @my_org_public = create(:plan, :publicly_visible, org: @client.user.org)
          @my_org_private = create(:plan, :privately_visible, org: @client.user.org)
          @my_org_organizational = create(:plan, :organisationally_visible, org: @client.user.org)
          @my_org_test = create(:plan, :is_test, org: @client.user.org)
        end

        it "returns any non-test plan if the ApiClient is 'trusted'" do
          @client.update(trusted: true)
          [@other_org_public, @other_org_private, @other_org_organizational,
           @my_org_public, @my_org_private, @my_org_organizational].each do |plan|
            get api_v2_plan_path(plan), headers: @headers

            expect(response.code).to eql('200'), "for plan: #{plan.inspect}"
            expect(response).to render_template('api/v2/_standard_response')
            expect(response).to render_template('api/v2/plans/_show')

            json = JSON.parse(response.body).with_indifferent_access
            expected = "plans/#{plan.id}"
            expect(json[:items].first[:dmp][:dmp_id][:identifier].end_with?(expected)).to be(true)
          end
        end

        it 'does not return plans for an other org' do
          [@other_org_private, @other_org_organizational, @other_org_test].each do |plan|
            get api_v2_plan_path(plan), headers: @headers

            expect(response.code).to eql('404')
            expect(response).to render_template('api/v2/_standard_response')
            expect(response).to render_template('api/v2/error')

            json = JSON.parse(response.body).with_indifferent_access
            expect(json[:items].empty?).to be(true)
            expect(json[:errors].length).to be(1)
            expect(json[:errors].first).to eql('Plan not found')
          end
        end

        it 'returns the publicly visible plan' do
          get api_v2_plan_path(@my_org_public), headers: @headers

          expect(response.code).to eql('200')
          expect(response).to render_template('api/v2/_standard_response')
          expect(response).to render_template('api/v2/plans/_show')

          json = JSON.parse(response.body).with_indifferent_access
          expected = "plans/#{@my_org_public.id}"
          expect(json[:items].first[:dmp][:dmp_id][:identifier].end_with?(expected)).to be(true)
        end

        it "returns the privately visible plan owned by the ApiClient's User" do
          get api_v2_plan_path(@my_org_private), headers: @headers

          expect(response.code).to eql('200')
          expect(response).to render_template('api/v2/_standard_response')
          expect(response).to render_template('api/v2/plans/_show')

          json = JSON.parse(response.body).with_indifferent_access
          expected = "plans/#{@my_org_private.id}"
          expect(json[:items].first[:dmp][:dmp_id][:identifier].end_with?(expected)).to be(true)
        end

        it "returns the organisationally visible plan related to the ApiClient's User's Org" do
          get api_v2_plan_path(@my_org_organizational), headers: @headers

          expect(response.code).to eql('200')
          expect(response).to render_template('api/v2/_standard_response')
          expect(response).to render_template('api/v2/plans/_show')

          json = JSON.parse(response.body).with_indifferent_access
          expected = "plans/#{@my_org_organizational.id}"
          expect(json[:items].first[:dmp][:dmp_id][:identifier].end_with?(expected)).to be(true)
        end
      end
    end

    describe 'POST /api/v1/plans - create' do
      before do
        orcid_scheme
        @json = JSON.parse(complete_create_json(client: @client)).with_indifferent_access
        @scheme = create(:identifier_scheme, name: @client.name.downcase)
        stub_ror_service
      end

      it 'returns 401 if the token is invalid' do
        @headers['Authorization'] = "Bearer #{SecureRandom.uuid}"
        post(api_v2_plans_path, params: @json.to_json, headers: @headers)

        expect(response.code).to eql('401')
        expect(response).to render_template('api/v2/_standard_response')
        expect(response).to render_template('api/v2/error')

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:items].empty?).to be(true)
        expect(json[:errors].length).to be(1)
        expect(json[:errors].first).to eql('token is invalid, expired or has been revoked')
      end

      it 'returns 403 if the ApiClient does not have the :create_dmps scope' do
        token = mock_client_credentials_token(api_client: @client, scopes: %i[read_dmps])
        @headers['Authorization'] = "Bearer #{token}"
        post(api_v2_plans_path, params: @json.to_json, headers: @headers)

        expect(response.code).to eql('403')
      end

      it 'fails if the Plan already exists (based on the specified :dmp_id)' do
        plan = create(:plan)
        id = @json[:dmp].fetch(:dmp_id, {})[:identifier]
        create(:identifier, identifiable: plan, value: id, identifier_scheme: @scheme)
        post(api_v2_plans_path, params: @json.to_json, headers: @headers)

        expect(response.code).to eql('400')
        expect(response).to render_template('api/v2/_standard_response')
        expect(response).to render_template('api/v2/error')

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:items].empty?).to be(true)
        expect(json[:errors].length).to be(1)
        expect(json[:errors].first).to eql('Plan already exists. Send an update instead.')
      end

      it 'fails if invalid JSON is passed' do
        Api::V2::Deserialization::Plan.stubs(:deserialize).raises(JSON::ParserError)
        post(api_v2_plans_path, params: @json.to_json, headers: @headers)

        expect(response.code).to eql('400')
        expect(response).to render_template('api/v2/_standard_response')
        expect(response).to render_template('api/v2/error')

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:items].empty?).to be(true)
        expect(json[:errors].length).to be(1)
        expect(json[:errors].first).to eql('Invalid JSON')
      end

      it 'fails if the JSON could not be deserialized to a Plan' do
        Api::V2::Deserialization::Plan.stubs(:deserialize).returns(nil)
        post(api_v2_plans_path, params: @json.to_json, headers: @headers)

        expect(response.code).to eql('400')
        expect(response).to render_template('api/v2/_standard_response')
        expect(response).to render_template('api/v2/error')

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:items].empty?).to be(true)
        expect(json[:errors].length).to be(1)
        expect(json[:errors].first).to eql('Invalid JSON format!')
      end

      it 'returns contextualized errors' do
        @json[:dmp][:contact] = {}
        post(api_v2_plans_path, params: @json.to_json, headers: @headers)

        expect(response.code).to eql('400')
        expect(response).to render_template('api/v2/_standard_response')
        expect(response).to render_template('api/v2/error')

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:items].empty?).to be(true)
        expect(json[:errors].length).to be(1)
        expect(json[:errors].first).to eql([":title and the contact's :mbox are both required fields"])
      end

      it 'creates the Plan' do
        post(api_v2_plans_path, params: @json.to_json, headers: @headers)

        expect(response.code).to eql('201'), "Unable to create Plan: #{response.body.inspect}"
        expect(response).to render_template('api/v2/_standard_response')
        expect(response).to render_template('api/v2/identifiers/_show')
        expect(response).to render_template('api/v2/orgs/_show')
        expect(response).to render_template('api/v2/contributors/_show')
        expect(response).to render_template('api/v2/plans/_funding')
        expect(response).to render_template('api/v2/plans/_project')
        expect(response).to render_template('api/v2/datasets/_show')
        expect(response).to render_template('api/v2/plans/_show')
        expect(response).to render_template('api/v2/plans/index')

        original = @json[:dmp]
        json = JSON.parse(response.body).with_indifferent_access
        created = json.fetch(:items, [{ dmp: {} }]).first[:dmp]
        dmp = Plan.find_by(id: created.fetch(:dmp_id, {})[:identifier].split('/').last)

        expect(dmp.present?).to be(true)
        expect(created[:title]).to eql(original[:title])
        expect(dmp.title).to eql(original[:title])

        expect(created[:description]).to eql(original[:description])
        expect(dmp.description).to eql(original[:description])

        # Defaulting lang to English for now since the Plan does not retain this info
        expect(created[:language]).to eql('eng')

        expect(created[:created]).to eql(dmp.created_at.to_formatted_s(:iso8601))
        expect(created[:modified]).to eql(dmp.updated_at.to_formatted_s(:iso8601))

        expect(created[:ethical_issues_exist]).to eql(original[:ethical_issues_exist])
        bool = Api::V2::ConversionService.yes_no_unknown_to_boolean(created[:ethical_issues_exist])
        expect(bool).to eql(dmp.ethical_issues)
        expect(created[:ethical_issues_description]).to eql(original[:ethical_issues_description])
        expect(created[:ethical_issues_report]).to eql(original[:ethical_issues_report])

        expect(created[:dmp_id][:type]).to eql('url')
        expect(created[:dmp_id][:identifier].end_with?(api_v2_plan_path(dmp))).to be(true)

        # Contact verification
        expect(created[:contact][:mbox]).to eql(original[:contact][:mbox])
        expect(created[:contact][:name]).to eql(original[:contact][:name])
        expect(created[:contact][:affiliation][:name]).to eql(original[:contact][:affiliation][:name])
        expect(created[:contact][:mbox]).to eql(dmp.owner.email)
        expect(created[:contact][:name]).to eql(dmp.owner.name(false))
        expect(created[:contact][:affiliation][:name]).to eql(dmp.owner.org.name)

        # Contributor verification
        expect(created[:contributor].length).to eql(original[:contributor].length)
        created[:contributor].each do |contributor|
          orig_contrib = original[:contributor].select do |c|
            c[:mbox] == contributor[:mbox] || c[:name] == contributor[:name]
          end

          contrib = Contributor.find_by(email: orig_contrib.first[:mbox])
          expect(contributor[:name]).to eql(orig_contrib.first[:name])
          expect(contributor[:mbox]).to eql(orig_contrib.first[:mbox])

          if contrib.email == created[:contact][:mbox]
            expect(contributor[:affiliation].present?).to be(true)
            expect(contributor[:affiliation][:name]).to eql(contrib.org.name)
          else
            # Unknown Orgs should not be created!
            expect(contributor[:affiliation].present?).to be(false)
          end

          expect(contributor[:name]).to eql(contrib.name)
          expect(contributor[:mbox]).to eql(contrib.email)

          contributor[:role].each do |role|
            expect(orig_contrib.first[:role].include?(role)).to be(true)
            r = Api::V2::DeserializationService.translate_role(role: role)
            expect(contrib.send(:"#{r}?")).to be(true)
          end
        end

        # Project Verification
        project = created.fetch(:project, [{}]).first
        # There is no Project model so the project->title and project->description should be
        # the same as the Plan's
        expect(created[:title]).to eql(project[:title])
        expect(created[:description]).to eql(project[:description])
        expect(Time.zone.local(project[:start])).to eql(Time.zone.local(original.fetch(:project, [{}]).first[:start]))
        expect(Time.zone.local(project[:end])).to eql(Time.zone.local(original.fetch(:project, [{}]).first[:end]))
        expect(project[:start]).to eql(dmp.start_date.to_formatted_s(:iso8601))
        expect(project[:end]).to eql(dmp.end_date.to_formatted_s(:iso8601))

        # Funding Verification
        funding = created.fetch(:project, [{}]).first.fetch(:funding, [{}]).first
        orig_funding = original.fetch(:project, [{}]).first.fetch(:funding, [{}]).first
        expect(funding[:name]).to eql(orig_funding[:name])
        expect(funding[:funding_status]).to eql(orig_funding[:funding_status])
        expect(funding[:grant_id][:identifier]).to eql(orig_funding[:grant_id][:identifier])
        opp_id = funding[:dmproadmap_funding_opportunity_id][:identifier]
        expect(opp_id).to eql(orig_funding[:dmproadmap_funding_opportunity_id][:identifier])
      end

      it 'sends an invitation email if the :contact is not already a User' do
        ActionMailer::Base.deliveries = []
        post(api_v2_plans_path, params: @json.to_json, headers: @headers)

        expect(response.code).to eql('201'), "Unable to create Plan: #{response.body.inspect}"
        expect(ActionMailer::Base.deliveries).to have_exactly(1).item
        expect(response).to render_template('user_mailer/new_plan_via_api')

        owner = Plan.find_by(title: @json[:dmp][:title]).owner
        expect(owner.firstname.present?).to be(true)
        expect(owner.surname.present?).to be(true)
        expect(owner.email.present?).to be(true)
        expect(owner.org.present?).to be(true)
        expect(owner.invitation_token.present?).to be(true)
        expect(owner.invitation_created_at.present?).to be(true)
        expect(owner.invitation_sent_at.present?).to be(true)
        expect(owner.plans.length).to be(1)
      end

      it 'sends an email notification of the new plan if the :contact is already a User' do
        contact = @json[:dmp][:contact]
        name_parts = contact[:name].split
        create(:user, firstname: name_parts.first, surname: name_parts.last, email: contact[:mbox])

        ActionMailer::Base.deliveries = []
        post(api_v2_plans_path, params: @json.to_json, headers: @headers)

        expect(response.code).to eql('201'), "Unable to create Plan: #{response.body.inspect}"
        expect(ActionMailer::Base.deliveries).to have_exactly(1).item
        expect(response).to render_template('user_mailer/new_plan_via_api')

        owner = Plan.find_by(title: @json[:dmp][:title]).owner
        expect(owner.firstname.present?).to be(true)
        expect(owner.surname.present?).to be(true)
        expect(owner.email.present?).to be(true)
        expect(owner.org.present?).to be(true)
        expect(owner.invitation_token.present?).to be(false)
        expect(owner.invitation_created_at.present?).to be(false)
        expect(owner.invitation_sent_at.present?).to be(false)
        expect(owner.plans.length).to be(1)
      end

      it 'logs the addition of the new plan in the api_logs' do
        post(api_v2_plans_path, params: @json.to_json, headers: @headers)
        expect(response.code).to eql('201'), "Unable to create Plan: #{response.body.inspect}"
        entry = ApiLog.all.last
        plan = Plan.all.last
        expected = "Created a new Plan:<br>#<Plan id: #{plan.id}, "
        expect(entry.present?).to be(true)
        expect(entry.api_client_id).to eql(@client.id)
        expect(entry.logable).to eql(plan)
        expect(entry.change_type).to eql('added')
        expect(entry.activity.start_with?(expected)).to be(true)
      end
    end
  end
end
