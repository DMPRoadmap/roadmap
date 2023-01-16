# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GuidancesController, type: :controller do
  before(:each) do
    @org = create(:org, managed: true)
    @user = create(:user, :org_admin, org: @org)
    @theme = create(:theme)
    @guidance_group = GuidanceGroup.create_org_default(@org)
    @guidance = create(:guidance, guidance_group_id: @guidance_group.id)

    @controller = described_class.new
    sign_in(@user)
  end

  it 'GET /org/admin/guidance/:id/admin_index' do
    get :admin_index, params: { id: @org.id }
    expect(response).to render_template('guidances/admin_index')
    ggs = assigns(:guidance_groups)
    gs = assigns(:guidances)
    expect(ggs.include?(@guidance_group)).to eql(true)
    expect(gs.include?(@guidance)).to eql(true)
  end

  it 'GET /org/admin/guidance/:id/admin_new (:admin_new)' do
    get :admin_new, params: { id: @org.id }
    expect(response).to render_template('guidances/new_edit')
    g = assigns(:guidance)
    expect(g.new_record?).to eql(true)
  end

  it 'GET /org/admin/guidance/:id/admin_edit (:admin_edit)' do
    get :admin_edit, params: { id: @guidance.id }
    expect(response).to render_template('guidances/new_edit')
    expect(assigns(:guidance)).to eql(@guidance)
  end

  describe 'POST /org/admin/guidance/:id/admin_create (:admin_create)' do
    it 'succeeds' do
      args = { text: Faker::Lorem.paragraph, published: Faker::Boolean.boolean,
               guidance_group_id: @guidance_group.id, theme_ids: [@theme.id] }
      post :admin_create, params: { id: @org.id, guidance: args }
      expect(response).to render_template('guidances/new_edit')
      expect(flash[:notice].present?).to eql(true)
      g = assigns(:guidance)
      expect(g.id).not_to eql(@guidance.id)
      expect(g.text).to eql(args[:text])
      expect(g.published).to eql(args[:published])
      expect(g.guidance_group_id).to eql(args[:guidance_group_id])
      expect(g.themes.first).to eql(@theme)
    end
    it 'fails' do
      args = { text: nil, guidance_group_id: nil }
      post :admin_create, params: { id: @org.id, guidance: args }
      expect(response).to render_template('guidances/new_edit')
      expect(flash[:alert].present?).to eql(true)
    end
    it 'publishes the GuidanceGroup' do
      @guidance_group.update(published: false)
      args = { text: Faker::Lorem.paragraph, published: true,
               guidance_group_id: @guidance_group.id, theme_ids: [@theme.id] }
      post :admin_create, params: { id: @org.id, guidance: args }
      expect(@guidance_group.reload.published).to eql(true)
    end
  end

  describe 'PUT /org/admin/guidance/:id/admin_update (:admin_update)' do
    it 'succeeds' do
      theme = create(:theme)
      gg = create(:guidance_group, org_id: @org.id)
      args = { text: Faker::Lorem.paragraph, published: Faker::Boolean.boolean,
               guidance_group_id: gg.id, theme_ids: [theme.id] }
      put :admin_update, params: { id: @guidance.id, guidance: args }
      expect(response).to render_template('guidances/new_edit')
      expect(flash[:notice].present?).to eql(true)
      g = assigns(:guidance)
      expect(g.id).to eql(@guidance.id)
      expect(g.text).to eql(args[:text])
      expect(g.published).to eql(args[:published])
      expect(g.guidance_group_id).to eql(gg.id)
      expect(g.themes.first).to eql(theme)
    end
    it 'fails' do
      args = { text: nil, guidance_group_id: nil }
      put :admin_update, params: { id: @guidance.id, guidance: args }
      expect(response).to render_template('guidances/new_edit')
      expect(flash[:alert].present?).to eql(true)
    end
    it 'publishes the GuidanceGroup' do
      @guidance_group.update(published: false)
      args = { text: Faker::Lorem.paragraph, published: true,
               guidance_group_id: @guidance_group.id, theme_ids: [@theme.id] }
      put :admin_update, params: { id: @guidance.id, guidance: args }
      expect(@guidance_group.reload.published).to eql(true)
    end
  end

  describe 'PUT /org/admin/guidance/:id/admin_update_publish (:admin_publish)' do
    before(:each) do
      @guidance.update(published: false)
    end

    it 'succeeds' do
      args = { published: true }
      put :admin_publish, params: { id: @guidance.id, guidance: args }
      expect(response).to redirect_to(admin_index_guidance_path)
      expect(flash[:notice].present?).to eql(true)
      expect(@guidance.reload.published?).to eql(true)
    end
    it 'fails' do
      Guidance.any_instance.stubs(:update).returns(false)
      args = { published: false }
      put :admin_publish, params: { id: @guidance.id, guidance: args }
      expect(response).to redirect_to(admin_index_guidance_path)
      expect(flash[:alert].present?).to eql(true)
      expect(@guidance.reload.published?).to eql(false)
    end
    it 'publishes the GuidanceGroup' do
      @guidance_group.update(published: false)
      args = { published: true }
      put :admin_publish, params: { id: @guidance.id, guidance: args }
      expect(@guidance_group.reload.published).to eql(true)
    end
  end

  describe 'PUT /org/admin/guidance/:id/admin_update_unpublish (:admin_unpublish)' do
    before(:each) do
      @guidance.update(published: true)
    end

    it 'succeeds' do
      args = { published: false }
      put :admin_unpublish, params: { id: @guidance.id, guidance: args }
      expect(response).to redirect_to(admin_index_guidance_path)
      expect(flash[:notice].present?).to eql(true)
      expect(@guidance.reload.published?).to eql(false)
    end
    it 'fails' do
      Guidance.any_instance.stubs(:update).returns(false)
      args = { published: true }
      put :admin_unpublish, params: { id: @guidance.id, guidance: args }
      expect(response).to redirect_to(admin_index_guidance_path)
      expect(flash[:alert].present?).to eql(true)
      expect(@guidance.reload.published?).to eql(true)
    end
    it 'unpublishes the GuidanceGroup if there is no other published guidance' do
      Guidance.where.not(id: @guidance.id).destroy_all
      @guidance_group.update(published: true)
      delete :admin_destroy, params: { id: @guidance.id }
      expect(@guidance_group.reload.published).to eql(false)
    end
    it 'does not unpublish the GuidanceGroup if there is other published guidance' do
      create(:guidance, guidance_group_id: @guidance_group.id, published: true)
      @guidance_group.update(published: true)
      delete :admin_destroy, params: { id: @guidance.id }
      expect(@guidance_group.reload.published).to eql(true)
    end
  end

  describe 'DELETE /org/admin/guidance/:id/admin_destroy (:admin_destroy)' do
    it 'succeeds' do
      delete :admin_destroy, params: { id: @guidance.id }
      expect(response).to redirect_to(admin_index_guidance_path)
      expect(flash[:notice].present?).to eql(true)
      expect(Guidance.where(id: @guidance.id).any?).to eql(false)
    end
    it 'fails' do
      Guidance.any_instance.stubs(:destroy).returns(false)
      delete :admin_destroy, params: { id: @guidance.id }
      expect(response).to redirect_to(admin_index_guidance_path)
      expect(flash[:alert].present?).to eql(true)
    end
    it 'unpublishes the GuidanceGroup if there is no other published guidance' do
      Guidance.where.not(id: @guidance.id).destroy_all
      @guidance_group.update(published: true)
      delete :admin_destroy, params: { id: @guidance.id }
      expect(@guidance_group.reload.published).to eql(false)
    end
    it 'does not unpublish the GuidanceGroup if there is other published guidance' do
      create(:guidance, guidance_group_id: @guidance_group.id, published: true)
      @guidance_group.update(published: true)
      delete :admin_destroy, params: { id: @guidance.id }
      expect(@guidance_group.reload.published).to eql(true)
    end
  end
end
