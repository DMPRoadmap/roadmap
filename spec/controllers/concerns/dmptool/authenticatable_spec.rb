# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dmptool::Authenticatable, type: :controller do
  include DmptoolHelper
  include OrgSelectionHelper
  include Devise::Test::ControllerHelpers

  before(:each) do
    @org = create(:org)

    @user = create(:user, org: @org)
    @admin = create(:user, :org_admin, org: @org)
    @super_admin = create(:user, :super_admin, org: @org)

    # Use a fake controller to test the concern
    # rubocop:disable Lint/ConstantDefinitionInBlock
    class FakeController < ApplicationController
      include OrgSelectable
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock

    @controller = FakeController.new

    mock_devise_env_for_controllers
  end

  after(:each) do
    # Make sure our FakeController class is destroyed!
    Object.send(:remove_const, :FakeController) if Object.const_defined?(:FakeController)
  end

  it 'Controllers includes our customizations' do
    expect(@controller.respond_to?(:user_from_omniauth)).to eql(true)
    expect(::Users::RegistrationsController.new.respond_to?(:user_from_omniauth)).to eql(true)
  end

  describe ':authentication_params(type:)' do
    it 'returns :email only if no :type is specified' do
      expect(@controller.send(:authentication_params, type: nil)).to eql(%i[email])
    end
    it 'returns the sign in params if :type is :sign_in' do
      expected = %i[email org_id password]
      expect(@controller.send(:authentication_params, type: 'sign_in')).to eql(expected)
    end
    it 'returns the sign up params if :type is :sign_up' do
      result = @controller.send(:authentication_params, type: 'sign_up')
      expect(result.include?(:accept_terms)).to eql(true)
      expect(result.include?(:email)).to eql(true)
      expect(result.include?(:firstname)).to eql(true)
      expect(result.include?(:language_id)).to eql(true)
      expect(result.include?(:org_id)).to eql(true)
      expect(result.include?(:password)).to eql(true)
      expect(result.include?(:surname)).to eql(true)

      org_hash = result.select { |i| !i.is_a?(Symbol) && i.keys.include?(:org_attributes) }.first
      expect(org_hash[:org_attributes].include?(:abbreviation)).to eql(true)
      expect(org_hash[:org_attributes].include?(:contact_email)).to eql(true)
      expect(org_hash[:org_attributes].include?(:contact_name)).to eql(true)
      expect(org_hash[:org_attributes].include?(:is_other)).to eql(true)
      expect(org_hash[:org_attributes].include?(:managed)).to eql(true)
      expect(org_hash[:org_attributes].include?(:name)).to eql(true)
      expect(org_hash[:org_attributes].include?(:org_type)).to eql(true)
      expect(org_hash[:org_attributes].include?(:target_url)).to eql(true)
      expect(org_hash[:org_attributes].include?(:links)).to eql(true)
    end
  end

  it 'returns a list of ignorable email domains' do
    expect(@controller.send(:ignored_email_domains).any?).to eql(true)
  end

  describe ':org_from_email_domain(email_domain:)' do
    it 'returns nil if no :email_domain is present' do
      expect(@controller.send(:org_from_email_domain, email_domain: nil)).to eql(nil)
    end
    it 'returns nil if :email_domain is one we want to ignore' do
      domain = @controller.send(:ignored_email_domains).sample
      expect(@controller.send(:org_from_email_domain, email_domain: domain)).to eql(nil)
    end
    it 'calls :lookup_registry_org_by_email' do
      @controller.expects(:lookup_registry_org_by_email).once.returns(@org)
      expect(@controller.send(:org_from_email_domain, email_domain: 'foo.edu')).to eql(@org)
    end
    it 'returns nil if no RegitryOrg matched and no other Users with that email domain exist' do
      @controller.expects(:lookup_registry_org_by_email).once.returns(nil)
      expect(@controller.send(:org_from_email_domain, email_domain: 'foo.edu')).to eql(nil)
    end
    it 'returns the Org with the most User records if there were multiple matches' do
      expected = create(:org)
      domain = 'valid-test-org.edu'
      @user.update(email: "user@#{domain}")
      5.times { create(:user, org: expected, email: "#{Faker::Lorem.unique.word}@#{domain}") }
      @controller.expects(:lookup_registry_org_by_email).once.returns(nil)
      # There should be 4 Users with the same email domain
      expect(::User.where('email LIKE ?', "%@#{domain.downcase}").count > 3).to eql(true)
      # It should return the Org that has 3 Users associated with it
      expect(@controller.send(:org_from_email_domain, email_domain: domain)).to eql(expected)
    end
  end

  describe ':lookup_registry_org_by_email(email_domain:)' do
    it 'returns nil if no :email_domain is present' do
      expect(@controller.send(:lookup_registry_org_by_email, email_domain: nil)).to eql(nil)
    end
    it 'returns nil if no RegistryOrg matched the :email_domain' do
      expect(@controller.send(:lookup_registry_org_by_email, email_domain: 'foo.bar')).to eql(nil)
    end
    it 'returns the closest matching RegistryOrg' do
      rorg1 = create(:registry_org)
      create(:registry_org, home_page: "#{rorg1.home_page}.foo")
      result = @controller.send(:lookup_registry_org_by_email, email_domain: rorg1.home_page.upcase)
      expected = rorg1.to_org
      expect(result.name).to eql(expected.name)
      expect(result.abbreviation).to eql(expected.abbreviation)
      expect(result.target_url).to eql(expected.target_url)
    end
  end

  describe ':user_from_omniauth' do
    before(:each) do
      @scheme1 = create(:identifier_scheme, :for_users)
      @scheme2 = create(:identifier_scheme, :for_users)
    end

    it 'searches for Devise session info for each applicable IdenitfierScheme' do
      @controller.expects(:session).twice.returns({})
      @controller.send(:user_from_omniauth)
    end
    it 'calls ::User.from_omniauth' do
      omniauth_hash = { "devise.#{@scheme1.name}_data": { foo: 'bar' } }.with_indifferent_access
      @controller.expects(:session).once.returns(omniauth_hash)
      ::User.expects(:from_omniauth).once.returns(@user)
      @controller.send(:user_from_omniauth)
    end
    it 'skips IdentifierSchemes if there is no corresponding Devise session info' do
      omniauth_hash = { "devise.#{@scheme2.name}_data": { foo: 'bar' } }.with_indifferent_access
      @controller.expects(:session).twice.returns({}, omniauth_hash)
      ::User.expects(:from_omniauth).once.returns(@user)
      @controller.send(:user_from_omniauth)
    end
  end

  context 'callbacks' do
    describe ':fetch_user' do
      it 'returns the user with the specified email' do
        params = { user: { email: @admin.email } }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        @controller.expects(:org_from_email_domain).never
        @controller.send(:fetch_user)
        resource = @controller.send(:resource)
        expect(resource).to eql(@admin)
        expect(resource.org).to eql(@admin.org)
      end
      it 'calls :org_from_email_domain if the initialized User does not have one' do
        params = { user: { email: 'foo@bar.edu' } }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        @controller.expects(:org_from_email_domain).once
        @controller.send(:fetch_user)
      end
      it 'calls :org_from_email_domain if User is a super_admin since they can switch orgs' do
        params = { user: { email: @super_admin.email } }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        @controller.expects(:org_from_email_domain).once
        @controller.send(:fetch_user)
      end
    end

    describe ':assign_instance_variables' do
      before(:each) do
        # This method attempts to access :resource so we need to call :fetch_user to set it
        params = { user: { email: @user.email } }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        @controller.send(:fetch_user)
      end

      it 'assigns the expected values' do
        @controller.send(:assign_instance_variables)
        expect(assigns(:main_class)).to eql('js-heroimage')
        expect(assigns(:shibbolized)).to eql(false)
      end
      it 'sets @shibbolized to true if the :org.shibbolized?' do
        shibbolize_org(org: @org)
        @controller.send(:assign_instance_variables)
        expect(assigns(:main_class)).to eql('js-heroimage')
        expect(assigns(:shibbolized)).to eql(true)
      end
    end

    describe ':humanize_params' do
      it 'succeeds if params that are being humanized are not included' do
        params = { user: { email: @user.email } }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        @controller.send(:humanize_params)
        expect(@controller.params[:user].keys.length).to eql(1)
      end
      it 'humanizes the user entered params' do
        params = {
          user: {
            email: @user.email,
            firstname: Faker::Music::PearlJam.musician.split.first.downcase,
            surname: Faker::Music::PearlJam.musician.split.last.downcase,
            org_autocomplete: { user_entered_name: Faker::Company.name.downcase }
          }
        }.with_indifferent_access

        @controller.stubs(:params).returns(params)
        @controller.send(:humanize_params)
        expect(@controller.params[:user].keys.length).to eql(4)
        expect(@controller.params[:user][:email]).to eql(params[:user][:email])
        expect(@controller.params[:user][:firstname]).to eql(params[:user][:firstname].humanize)
        expect(@controller.params[:user][:surname]).to eql(params[:user][:surname].humanize)
        org_name = params[:user][:org_autocomplete][:user_entered_name].humanize
        expect(@controller.params[:user][:org_autocomplete][:user_entered_name]).to eql(org_name)
      end
    end

    describe ':ensure_language' do
      it 'uses the :language_id specified in the params' do
        language = create(:language)
        params = { user: { language_id: language.id } }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        @controller.send(:ensure_language)
        expect(@controller.params[:user][:language_id]).to eql(language.id)
      end
      it 'skips the :language_id if I18n.locale is not defined and no :language_id specified' do
        I18n.stubs(:locale).returns(nil)
        params = { user: {} }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        @controller.send(:ensure_language)
        expect(@controller.params[:user][:language_id]).to eql(nil)
      end
      it 'uses the I18n.locale if no :language_id was specified in the params' do
        language = create(:language)
        I18n.stubs(:locale).returns(language.abbreviation)
        params = { user: {} }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        @controller.send(:ensure_language)
        expect(@controller.params[:user][:language_id]).to eql(language.id)
      end
    end

    describe ':ensure_org_param' do
      it 'calls OrgSelectable.autocomplete_to_controller_params and sets the org params' do
        params = { user: { email: @user.email } }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        @controller.stubs(:org_selectable_params).returns({})
        @controller.send(:ensure_org_param)
      end
      it 'sets the :org_id param if this is a known User' do
        params = { user: { email: @user.email, org_id: @org.id } }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        @controller.stubs(:org_selectable_params).returns({})
        @controller.send(:ensure_org_param)
        expect(@controller.params[:user][:org_id]).to eql(@org.id)
        expect(@controller.params[:user][:org_attributes]).to eql(nil)
      end
      it 'sets the :org_id param if the User selected an Org from the autocomplete' do
        org_attrs = params_for_known_org_selection(org: @org)
        params = { user: { email: Faker::Internet.unique.email } }.with_indifferent_access
        @controller.stubs(:org_selectable_params).returns(org_attrs)
        @controller.stubs(:params).returns(params)
        @controller.send(:ensure_org_param)
        expect(@controller.params[:user][:org_id]).to eql(@org.id)
        expect(@controller.params[:user][:org_attributes]).to eql(nil)
      end
    end
  end
end
