# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrgsController, type: :controller do
  include Mocks::FormFieldJsonValues

  before(:each) do
    @name = Faker::Company.name
    @org = create(:org)
    @user = create(:user, :super_admin, org: @org)
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
                contact_email: Faker::Internet.email,
                contact_name: Faker::Movies::StarWars.character,
                organisation: [true, false].sample,
                funder: [true, false].sample, institution: [true, false].sample,
                managed: Faker::Number.within(range: 0..1).to_s,
                feedback_enabled: Faker::Boolean.boolean,
                feedback_msg: Faker::Lorem.paragraph,
                org_autocomplete: { name: other_org.name } }
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
end
