# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dmptool::Authenticatable do
  include Helpers::DmptoolHelper
  include Helpers::IdentifierHelper
  include Helpers::OrgSelectionHelper
  include Devise::Test::ControllerHelpers

  before do
    @org = create(:org)

    @user = create(:user, org: @org)
    @admin = create(:user, :org_admin, org: @org)
    @super_admin = create(:user, :super_admin, org: @org)

    # Use a fake controller to test the concern
    # rubocop:disable Lint/ConstantDefinitionInBlock
    class FakeController < ApplicationController
      include Dmptool::Authenticatable

      # Only controllers that inherit from Devise use the Authenticatable concern so stub :resource
      attr_accessor :resource
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock

    @controller = FakeController.new

    mock_devise_env_for_controllers
  end

  after do
    # Make sure our FakeController class is destroyed!
    Object.send(:remove_const, :FakeController) if Object.const_defined?(:FakeController)
  end

  it 'Controllers includes our customizations' do
    expect(@controller.respond_to?(:user_from_omniauth)).to be(true)
    expect(Users::RegistrationsController.new.respond_to?(:user_from_omniauth)).to be(true)
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
      expect(result.include?(:accept_terms)).to be(true)
      expect(result.include?(:email)).to be(true)
      expect(result.include?(:firstname)).to be(true)
      expect(result.include?(:language_id)).to be(true)
      expect(result.include?(:org_id)).to be(true)
      expect(result.include?(:password)).to be(true)
      expect(result.include?(:surname)).to be(true)

      org_hash = result.find { |i| !i.is_a?(Symbol) && i.key?(:org_attributes) }
      expect(org_hash[:org_attributes].include?(:abbreviation)).to be(true)
      expect(org_hash[:org_attributes].include?(:contact_email)).to be(true)
      expect(org_hash[:org_attributes].include?(:contact_name)).to be(true)
      expect(org_hash[:org_attributes].include?(:is_other)).to be(true)
      expect(org_hash[:org_attributes].include?(:managed)).to be(true)
      expect(org_hash[:org_attributes].include?(:name)).to be(true)
      expect(org_hash[:org_attributes].include?(:org_type)).to be(true)
      expect(org_hash[:org_attributes].include?(:target_url)).to be(true)
      expect(org_hash[:org_attributes].include?(:links)).to be(true)
    end
  end

  describe ':user_from_omniauth' do
    before do
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
      User.expects(:from_omniauth).once.returns(@user)
      @controller.send(:user_from_omniauth)
    end

    it 'skips IdentifierSchemes if there is no corresponding Devise session info' do
      omniauth_hash = { "devise.#{@scheme2.name}_data": { foo: 'bar' } }.with_indifferent_access
      @controller.expects(:session).twice.returns({}, omniauth_hash)
      User.expects(:from_omniauth).once.returns(@user)
      @controller.send(:user_from_omniauth)
    end
  end

  context 'callbacks' do
    describe ':fetch_user' do
      it 'returns the user with the specified email' do
        params = { user: { email: @admin.email } }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        Org.expects(:from_email_domain).never
        @controller.send(:fetch_user)
        resource = @controller.send(:resource)
        expect(resource).to eql(@admin)
        expect(resource.org).to eql(@admin.org)
      end

      it 'calls :org_from_email_domain if the initialized User does not have one' do
        params = { user: { email: 'foo@bar.edu' } }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        Org.expects(:from_email_domain).once
        @controller.send(:fetch_user)
      end

      it 'calls :org_from_email_domain if User is a super_admin since they can switch orgs' do
        params = { user: { email: @super_admin.email } }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        Org.expects(:from_email_domain).once
        @controller.send(:fetch_user)
      end
    end

    describe ':assign_instance_variables' do
      before do
        # This method attempts to access :resource so we need to call :fetch_user to set it
        params = { user: { email: @user.email } }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        @controller.send(:fetch_user)
      end

      it 'assigns the expected values' do
        @controller.send(:assign_instance_variables)
        expect(assigns(:main_class)).to eql('js-heroimage')
        expect(assigns(:shibbolized)).to be(false)
      end

      it 'sets @shibbolized to true if the :org.shibbolized?' do
        shibbolize_org(org: @org)
        @controller.send(:assign_instance_variables)
        expect(assigns(:main_class)).to eql('js-heroimage')
        expect(assigns(:shibbolized)).to be(true)
      end
    end

    describe ':humanize_params' do
      it 'succeeds if params that are being humanized are not included' do
        params = { user: { email: @user.email } }.with_indifferent_access
        @controller.stubs(:params).returns(params)
        @controller.send(:humanize_params)
        expect(@controller.params[:user].keys.length).to be(1)
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
        expect(@controller.params[:user].keys.length).to be(4)
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
        expect(@controller.params[:user][:language_id]).to be_nil
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
        expect(@controller.params[:user][:org_attributes]).to be_nil
      end

      it 'sets the :org_id param if the User selected an Org from the autocomplete' do
        org_attrs = params_for_known_org_selection(org: @org)
        params = { user: { email: Faker::Internet.unique.email } }.with_indifferent_access
        @controller.stubs(:org_selectable_params).returns(org_attrs)
        @controller.stubs(:params).returns(params)
        @controller.send(:ensure_org_param)
        expect(@controller.params[:user][:org_id]).to eql(@org.id)
        expect(@controller.params[:user][:org_attributes]).to be_nil
      end
    end
  end
end
