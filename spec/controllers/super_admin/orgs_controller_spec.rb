# frozen_string_literal: true

require "rails_helper"

RSpec.describe SuperAdmin::OrgsController, type: :controller do

  before(:each) do
    @scheme = create(:identifier_scheme)
    tpt = create(:token_permission_type)
    @from_org = create(:org, :funder, templates: 1, plans: 2, managed: true,
                                      feedback_enabled: true,
                                      token_permission_types: [tpt])
    create(:annotation, org: @from_org)
    create(:department, org: @from_org)
    gg = @from_org.guidance_groups.first if @from_org.guidance_groups.any?
    gg = create(:guidance_group, org: @from_org) unless gg.present?
    create(:guidance, guidance_group: gg)
    create(:identifier, identifiable: @from_org, identifier_scheme: nil)
    create(:identifier, identifiable: @from_org, identifier_scheme: @scheme)
    create(:plan, funder: @from_org)
    create(:tracker, org: @from_org)
    create(:user, org: @from_org)

    @from_org.reload
    @to_org = create(:org, :institution, plans: 2, managed: false)
    @user = create(:user, :super_admin)

    @attributes = {
      managed: @from_org.managed,
      target_url: @from_org.target_url,
      links: @from_org.links,
      logo_uid: @from_org.logo_uid,
      logo_name: @from_org.logo_name,
      contact_name: @from_org.contact_name,
      contact_email: @from_org.contact_email,
      feedback_enabled: @from_org.feedback_enabled,
      feedback_email_subject: @from_org.feedback_email_subject,
      feedback_email_msg: @from_org.feedback_email_msg
    }
    @associations = {
      "guidances": @from_org.guidance_groups.first.guidances,
      "identifiers": @from_org.identifiers.reject { |id| id.identifier_scheme.present? },
      "token_permission_types": @from_org.token_permission_types,
      "annotations": @from_org.annotations,
      "departments": @from_org.departments,
      "funded_plans": @from_org.funded_plans,
      "templates": @from_org.templates,
      "tracker": [@from_org.tracker],
      "users": @from_org.users
    }

    @controller = described_class.new
    sign_in(@user)
  end

  describe "POST /super_admin/:id/merge_analyze", js: true do
    before(:each) do
      @params = {
        "id": @from_org.id,
        # Send over the Org typehead json in the org.id field so the service can unpackage it
        "org": { "id": { "id": @to_org.id, "name": @to_org.name }.to_json }
      }
    end

    it "fails if user is not a super admin" do
      sign_in(create(:user))
      post :merge_analyze, params: @params
      expect(response.code).to eql("302")
      expect(response).to redirect_to(plans_path)
      expect(flash[:alert].present?).to eql(true)
    end
    it "succeeds in analyzing the Orgs" do
      post :merge_analyze, params: @params, format: :js
      expect(response.code).to eql("200")
      expect(assigns(:org)).to eql(@from_org)
      expect(assigns(:target_org)).to eql(@to_org)
      expect(response).to render_template(:merge_analyze)
    end
  end

  describe "POST /super_admin/:id/merge_commit", js: true do
    context "standard question type (no question_options and not RDA metadata)" do
      before(:each) do
        @params = {
          "id": @from_org.id,
          "org": {
            "target_org": @to_org.id,
            "mergeable_attributes": @attributes.to_json,
            "mergeable_associations": @associations.to_json
          }
        }
      end

      it "fails if user is not a super admin" do
        sign_in(create(:user))
        post :merge_commit, params: @params, format: :js
        expect(response.code).to eql("302")
        expect(response).to redirect_to(plans_path)
        expect(flash[:alert].present?).to eql(true)
      end
      it "fails if :target_org is not found" do
        @params[:org][:target_org] = 9999
        post :merge_commit, params: @params, format: :js
        expect(response.code).to eql("302")
        expect(response).to redirect_to(admin_edit_org_path(@from_org))
        expect(flash[:alert].present?).to eql(true)
      end
      it "fails if :mergeable_associations and mergeable_attributes is not found" do
        @params[:org][:mergeable_attributes] = nil
        @params[:org][:mergeable_associations] = nil
        post :merge_commit, params: @params, format: :js
        expect(response.code).to eql("302")
        expect(response).to redirect_to(admin_edit_org_path(@from_org))
        expect(flash[:alert].present?).to eql(true)
      end
      it "calls :merge_records" do
        expected = @from_org.tracker.code
        post :merge_commit, params: @params, format: :js
        expect(@to_org.reload.tracker.code).to eql(expected)
      end
      it "deletes all :guidance_groups on the :org" do
        org_id = @from_org.id
        post :merge_commit, params: @params, format: :js
        expect(GuidanceGroup.where(org_id: org_id).any?).to eql(false)
      end
      it "deletes all :identifiers on the :org" do
        org_id = @from_org.id
        post :merge_commit, params: @params, format: :js
        results = Identifier.where(identifiable_id: org_id, identifiable_type: "Org")
        expect(results.any?).to eql(false)
      end
      it "deletes the :org" do
        org_id = @from_org.id
        post :merge_commit, params: @params, format: :js
        expect(Org.where(id: org_id).any?).to eql(false)
      end
      it "succeeds and redirects properly" do
        post :merge_commit, params: @params, format: :js
        expect(response.code).to eql("302")
        expect(response).to redirect_to(super_admin_orgs_path)
      end
    end
  end

  context "private methods" do
    describe ":merge_records(org:, target_org:, attributes:, associations:)" do
      it "updates the appropriate attributes on Org" do
        @controller.send(:merge_records, org: @from_org, target_org: @to_org,
                                         attributes: @attributes, associations: {})
        @to_org.reload
        expect(@to_org.managed).to eql(@from_org.managed)
        expect(@to_org.target_url).to eql(@from_org.target_url)
        expect(@to_org.links).to eql(@from_org.links)
        expect(@to_org.logo_uid).to eql(@from_org.logo_uid)
        expect(@to_org.logo_name).to eql(@from_org.logo_name)
        expect(@to_org.contact_name).to eql(@from_org.contact_name)
        expect(@to_org.contact_email).to eql(@from_org.contact_email)
        expect(@to_org.feedback_enabled).to eql(@from_org.feedback_enabled)
        expect(@to_org.feedback_email_subject).to eql(@from_org.feedback_email_subject)
        expect(@to_org.feedback_email_msg).to eql(@from_org.feedback_email_msg)
      end
      it "does not update the Org attributes that should not be changed" do
        @controller.send(:merge_records, org: @from_org, target_org: @to_org,
                                         attributes: @attributes, associations: {})
        @to_org.reload
        expect(@to_org.name).not_to eql(@from_org.name)
        expect(@to_org.abbreviation).not_to eql(@from_org.abbreviation)
        expect(@to_org.org_type).not_to eql(@from_org.org_type)
      end
      it "moves :guidance to the existing GuidanceGroup" do
        gg = @to_org.guidance_groups.first if @to_org.guidance_groups.any?
        gg = create(:guidance_group, org: @to_org) unless gg.present?
        expected = GuidanceGroup.where(org: @from_org).last.guidances.length

        @controller.send(:merge_records, org: @from_org, target_org: @to_org.reload,
                                         attributes: {}, associations: @associations)

        expect(@to_org.guidance_groups.last).to eql(gg)
        expect(GuidanceGroup.where(org: @to_org).last.guidances.length).to eql(expected)
      end
      it "moves :guidance to a new GuidanceGroup if none exists" do
        GuidanceGroup.where(org: @to_org).destroy_all
        expected = GuidanceGroup.where(org: @from_org).last.guidances.length

        @controller.send(:merge_records, org: @from_org, target_org: @to_org.reload,
                                         attributes: {}, associations: @associations)

        expect(@to_org.reload.guidance_groups.length).to eql(1)
        expect(GuidanceGroup.where(org: @to_org).last.guidances.length).to eql(expected)
      end
      it "moves :identifiers" do
        expected = @associations[:identifiers].first

        @controller.send(:merge_records, org: @from_org, target_org: @to_org.reload,
                                         attributes: {}, associations: @associations)

        expect(@to_org.identifiers.map(&:value).include?(expected.value)).to eql(true)
      end
      it "moves :token_permission_types" do
        expected = @associations[:token_permission_types].length

        @controller.send(:merge_records, org: @from_org, target_org: @to_org.reload,
                                         attributes: {}, associations: @associations)

        expect(@to_org.token_permission_types.length).to eql(expected)
      end
      it "moves :annotations" do
        expected = @associations[:annotations].first.text

        @controller.send(:merge_records, org: @from_org, target_org: @to_org.reload,
                                         attributes: {}, associations: @associations)

        expect(@to_org.annotations.map(&:text).include?(expected)).to eql(true)
      end
      it "moves :departments" do
        expected = @associations[:departments].first.name

        @controller.send(:merge_records, org: @from_org, target_org: @to_org.reload,
                                         attributes: {}, associations: @associations)

        expect(@to_org.departments.map(&:name).include?(expected)).to eql(true)
      end
      it "moves :funded_plans" do
        expected = @associations[:funded_plans].first.title

        @controller.send(:merge_records, org: @from_org, target_org: @to_org.reload,
                                         attributes: {}, associations: @associations)

        expect(@to_org.funded_plans.map(&:title).include?(expected)).to eql(true)
      end
      it "moves :templates" do
        expected = @associations[:templates].first.title

        @controller.send(:merge_records, org: @from_org, target_org: @to_org.reload,
                                         attributes: {}, associations: @associations)

        expect(@to_org.templates.map(&:title).include?(expected)).to eql(true)
      end
      it "moves :tracker" do
        expected = @associations[:tracker].first.code

        @controller.send(:merge_records, org: @from_org, target_org: @to_org.reload,
                                         attributes: {}, associations: @associations)

        expect(@to_org.reload.tracker.code).to eql(expected)
      end
      it "moves :users" do
        expected = @associations[:users].first.email

        @controller.send(:merge_records, org: @from_org, target_org: @to_org.reload,
                                         attributes: {}, associations: @associations)

        expect(@to_org.users.map(&:email).include?(expected)).to eql(true)
      end
    end
  end

end
