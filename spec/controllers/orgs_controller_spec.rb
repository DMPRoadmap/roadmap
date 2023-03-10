# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrgsController, type: :controller do
  include Mocks::FormFieldJsonValues

  before(:each) do
    @name = Faker::Company.name
    @org = create(:org)
    @user = create(:user, :super_admin, org: @org)
    @logo = Rack::Test::UploadedFile.new 'spec/support/mocks/logo_file.png', 'image/png'
    @controller = OrgsController.new
  end

  it 'GET /org/admin/:id/admin_edit' do
    sign_in(@user)
    get :admin_edit, params: { id: @org.id }
    expect(response).to render_template('orgs/admin_edit')
  end

  describe 'PUT /org/admin/:id/admin_update' do
    before(:each) do
      other_org = build(:org, name: Faker::Movies::StarWars.unique.planet)
      @args = { name: Faker::Movies::StarWars.unique.planet,
                abbreviation: Faker::Lorem.unique.word.upcase,
                logo: @logo, contact_email: Faker::Internet.email,
                contact_name: Faker::Movies::StarWars.character,
                remove_logo: false, organisation: [true, false].sample,
                funder: [true, false].sample, institution: [true, false].sample,
                managed: Faker::Number.within(range: 0..1).to_s,
                feedback_enabled: Faker::Boolean.boolean,
                feedback_msg: Faker::Lorem.paragraph,
                org_id: org_selector_id_field(org: other_org), org_name: other_org.name,
                org_crosswalk: org_selector_crosswalk_field(org: other_org) }
      @link_args = org_links_field
      Rails.configuration.x.shibboleth.use_filtered_discovery_service = false
      sign_in(@user)
    end

    it 'succeeds' do
      @args.delete(:feedback_enabled)
      put :admin_update, params: { id: @org.id, org_links: @link_args, org: @args }
      expect(response).to redirect_to("#{admin_edit_org_path(@org)}#profile")
      expect(flash[:notice].present?).to eql(true)
      @org.reload
      expect(@org.name).to eql(@args[:name])
      expect(@org.abbreviation).to eql(@args[:abbreviation])
      expect(@org.contact_email).to eql(@args[:contact_email])
      expect(@org.contact_name).to eql(@args[:contact_name])
      expect(@org.funder?).to eql(@args[:funder])
      expect(@org.institution?).to eql(@args[:institution])
      expect(@org.organisation?).to eql(@args[:organisation])
      expect(@org.managed).to eql(@args[:managed] == '1')
      expect(@org.links.to_json).to eql(@link_args)
      expect(@org.logo_name).to eql('logo_file.png')
      expect(@org.logo_uid.present?).to eql(true)
    end
    it 'succeeds for feedback changes' do
      put :admin_update, params: { id: @org.id, org: @args }
      expect(response).to redirect_to("#{admin_edit_org_path(@org)}#feedback")
      expect(flash[:notice].present?).to eql(true)
      @org.reload
      expect(@org.feedback_enabled).to eql(@args[:feedback_enabled])
      expect(@org.feedback_msg).to eql(@args[:feedback_msg])
    end
    it 'updates the shibboleth entityID if super_admin and enabled' do
      @args.delete(:feedback_enabled)
      Rails.configuration.x.shibboleth.use_filtered_discovery_service = true
      scheme = create(:identifier_scheme, name: 'shibboleth')
      @args[:identifiers_attributes] = { '0': { identifier_scheme_id: scheme.id,
                                                value: SecureRandom.uuid } }
      put :admin_update, params: { id: @org.id, org: @args }
      expect(response).to redirect_to("#{admin_edit_org_path(@org)}#profile")
      expect(flash[:notice].present?).to eql(true)
      identifier = @org.reload.identifiers.last
      expect(identifier.present?).to eql(true)
      expect(identifier.identifier_scheme).to eql(scheme)
      expected = @args[:identifiers_attributes][:'0'][:value]
      expect(identifier.value.end_with?(expected)).to eql(true)
    end
    it 'fails' do
      put :admin_update, params: { id: @org.id, org: { name: nil } }
      expect(response).to redirect_to("#{admin_edit_org_path(@org)}#profile")
      expect(flash[:alert].present?).to eql(true)
    end
  end

  describe 'GET /orgs/shibboleth_ds' do
    before(:each) do
      shib = create(:identifier_scheme, name: 'shibboleth')
      @identifier = create(:identifier, identifier_scheme: shib,
                                        identifiable: @org, value: SecureRandom.uuid)
    end

    it 'succeeds' do
      get :shibboleth_ds
      expect(response).to render_template('orgs/shibboleth_ds')
      expect(assigns(:user).new_record?).to eql(true)
      expect(assigns(:orgs).any?).to eql(true)
      expect(assigns(:orgs).include?(@org)).to eql(true)
    end
    it 'redirects to the dashboard if user is logged in' do
      sign_in(@user)
      get :shibboleth_ds
      expect(response).to redirect_to(root_path)
    end
    it 'redirects to the user omniauth path if no Orgs have shib entityIDs' do
      @identifier.destroy
      get :shibboleth_ds
      expect(response).to redirect_to(user_shibboleth_omniauth_authorize_path)
      expect(flash[:alert].present?).to eql(true)
    end
  end

  describe 'POST /orgs/shibboleth_ds' do
    before(:each) do
      shib = create(:identifier_scheme, name: 'shibboleth')
      @identifier = create(:identifier, identifier_scheme: shib,
                                        identifiable: @org, value: SecureRandom.uuid)
    end

    it 'succeeds' do
      post :shibboleth_ds_passthru, params: { org_id: @org.id }
      url = @controller.send(:shib_login_url)
      target = @controller.send(:shib_callback_url)
      expected = "#{url}?#{target}&entityID=#{@identifier.value}"
      expect(response).to redirect_to(expected)
    end
    it 'receives no [:org_id] information' do
      post :shibboleth_ds_passthru, params: {}
      expect(response).to redirect_to(shibboleth_ds_path)
      expect(flash[:notice].present?).to eql(true)
    end
    it 'is for an Org that does not have a shibboleth entityID defined' do
      @identifier.destroy
      post :shibboleth_ds_passthru, params: { org_id: @org.id }
      expect(response).to redirect_to(shibboleth_ds_path)
      expect(flash[:alert].present?).to eql(true)
    end
  end

  describe 'POST /orgs' do
    before(:each) do
      uri = URI.parse(Faker::Internet.url)
      @hash = { id: uri.to_s, name: "#{@name} (#{uri.host})", sort_name: @name,
                score: 0, weight: 1 }
    end

    it 'returns an empty array if the search term is blank' do
      OrgSelection::SearchService.stubs(:search_locally).returns([@hash])
      post :search, params: { org: { name: '' } }, format: :js
      expect(JSON.parse(response.body)).to eql([])
    end

    it 'returns an empty array if the search term is less than 3 characters' do
      OrgSelection::SearchService.stubs(:search_locally).returns([@hash])
      post :search, params: { org: { name: 'Fo' } }, format: :js
      expect(JSON.parse(response.body)).to eql([])
    end

    it 'assigns the orgs variable' do
      OrgSelection::SearchService.stubs(:search_locally).returns([@hash])
      post :search, params: { org: { name: Faker::Lorem.sentence } }, format: :js
      json = JSON.parse(response.body)
      expect(json.length).to eql(1)
      expect(json.first['sort_name']).to eql(@name)
    end

    it 'calls search_locally by default' do
      OrgSelection::SearchService.expects(:search_locally).at_least(1)
      post :search, params: { org: { name: Faker::Lorem.sentence } }, format: :js
    end

    it 'calls search_externally when query string contains type=external' do
      OrgSelection::SearchService.expects(:search_externally).at_least(1)
      post :search, params: { org: { name: Faker::Lorem.sentence }, type: 'external' },
                    format: :js
    end

    it 'calls search_combined when query string contains type=combined' do
      OrgSelection::SearchService.expects(:search_combined).at_least(1)
      post :search, params: { org: { name: Faker::Lorem.sentence }, type: 'combined' },
                    format: :js
    end
  end
end
