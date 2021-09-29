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
        @params = { "id": @from_org.id, "org": { "target_org": @to_org.id } }
      end

      it "fails if user is not a super admin" do
        sign_in(create(:user))
        post :merge_commit, params: @params
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
      it "succeeds and redirects properly" do
        post :merge_commit, params: @params, format: :js
        expect(response.code).to eql("302")
        expect(response).to redirect_to(super_admin_orgs_path)
      end
    end
  end

end
