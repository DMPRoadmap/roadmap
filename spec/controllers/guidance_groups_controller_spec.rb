# frozen_string_literal: true

require "rails_helper"

RSpec.describe GuidanceGroupsController, type: :controller do

  before(:each) do
    @org = create(:org, managed: true)
    @user = create(:user, :org_admin, org: @org)
    # The Org factory auto-creates a guidance_group
    @guidance_group = GuidanceGroup.create_org_default(@org)

    @controller = described_class.new
    sign_in(@user)
  end

  it "GET /org/admin/guidancegroup/:id/admin_new (:admin_new)" do
    get :admin_new, params: { id: @org.id }
    expect(response).to render_template("guidance_groups/admin_new")
    gg = assigns(:guidance_group)
    expect(gg.new_record?).to eql(true)
    expect(gg.org_id).to eql(@org.id)
  end

  it "GET /org/admin/guidancegroup/:id/admin_edit (:admin_edit)" do
    get :admin_edit, params: { id: @guidance_group.id }
    expect(response).to render_template("guidance_groups/admin_edit")
    expect(assigns(:guidance_group)).to eql(@guidance_group)
  end

  describe "POST /org/admin/guidancegroup/:id/admin_create (:admin_create)" do
    it "succeeds" do
      args = { name: Faker::Lorem.sentence, published: Faker::Boolean.boolean,
               optional_subset: Faker::Boolean.boolean, org_id: @org.id }
      post :admin_create, params: { id: @org.id, guidance_group: args }
      expect(response).to render_template("guidance_groups/admin_edit")
      expect(flash[:notice].present?).to eql(true)
      gg = assigns(:guidance_group)
      expect(gg.id).not_to eql(@guidance_group.id)
      expect(gg.name).to eql(args[:name])
      expect(gg.published).to eql(args[:published])
      expect(gg.optional_subset).to eql(args[:optional_subset])
      expect(gg.org_id).to eql(args[:org_id])
    end
    it "fails" do
      args = { name: nil }
      post :admin_create, params: { id: @org.id, guidance_group: args }
      expect(response).to render_template("guidance_groups/admin_new")
      expect(flash[:alert].present?).to eql(true)
    end
  end

  describe "PUT /org/admin/guidancegroup/:id/admin_update (:admin_update)" do
    it "succeeds" do
      args = { name: Faker::Lorem.sentence, published: Faker::Boolean.boolean,
               optional_subset: Faker::Boolean.boolean }
      put :admin_update, params: { id: @guidance_group.id, guidance_group: args }
      expect(response).to render_template("guidance_groups/admin_edit")
      expect(flash[:notice].present?).to eql(true)
      gg = assigns(:guidance_group)
      expect(gg.id).to eql(@guidance_group.id)
      expect(gg.name).to eql(args[:name])
      expect(gg.published).to eql(args[:published])
      expect(gg.optional_subset).to eql(args[:optional_subset])
      expect(gg.org_id).to eql(@org.id)
    end
    it "fails" do
      args = { name: nil }
      put :admin_update, params: { id: @guidance_group.id, guidance_group: args }
      expect(response).to render_template("guidance_groups/admin_edit")
      expect(flash[:alert].present?).to eql(true)
    end
  end

  describe "PUT /org/admin/guidancegroup/:id/admin_update_publish (:admin_update_publish)" do
    before(:each) do
      @guidance_group.update(published: false)
    end

    it "succeeds" do
      args = { published: true }
      put :admin_update_publish, params: { id: @guidance_group.id, guidance_group: args }
      expect(response).to redirect_to(admin_index_guidance_path)
      expect(flash[:notice].present?).to eql(true)
      expect(@guidance_group.reload.published?).to eql(true)
    end
    it "fails" do
      GuidanceGroup.any_instance.stubs(:update).returns(false)
      args = { published: false }
      put :admin_update_publish, params: { id: @guidance_group.id, guidance_group: args }
      expect(response).to redirect_to(admin_index_guidance_path)
      expect(flash[:alert].present?).to eql(true)
      expect(@guidance_group.reload.published?).to eql(false)
    end
  end

  describe "PUT /org/admin/guidancegroup/:id/admin_update_unpublish (:admin_update_unpublish)" do
    before(:each) do
      @guidance_group.update(published: true)
    end

    it "succeeds" do
      args = { published: false }
      put :admin_update_unpublish, params: { id: @guidance_group.id, guidance_group: args }
      expect(response).to redirect_to(admin_index_guidance_path)
      expect(flash[:notice].present?).to eql(true)
      expect(@guidance_group.reload.published?).to eql(false)
    end
    it "fails" do
      GuidanceGroup.any_instance.stubs(:update).returns(false)
      args = { published: true }
      put :admin_update_unpublish, params: { id: @guidance_group.id, guidance_group: args }
      expect(response).to redirect_to(admin_index_guidance_path)
      expect(flash[:alert].present?).to eql(true)
      expect(@guidance_group.reload.published?).to eql(true)
    end
  end

  describe "DELETE /org/admin/guidancegroup/:id/admin_destroy (:admin_destroy)" do
    it "succeeds" do
      delete :admin_destroy, params: { id: @guidance_group.id }
      expect(response).to redirect_to(admin_index_guidance_path)
      expect(flash[:notice].present?).to eql(true)
      expect(GuidanceGroup.where(id: @guidance_group.id).any?).to eql(false)
    end
    it "fails" do
      GuidanceGroup.any_instance.stubs(:destroy).returns(false)
      delete :admin_destroy, params: { id: @guidance_group.id }
      expect(response).to redirect_to(admin_index_guidance_path)
      expect(flash[:alert].present?).to eql(true)
    end
  end

end
