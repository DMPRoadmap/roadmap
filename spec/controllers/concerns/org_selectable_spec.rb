# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrgSelectable do
  before do
    @org_term = Faker::Movies::StarWars.unique.character
    @funder_term = Faker::Movies::StarWars.unique.character

    @org_selection_params = {
      org_autocomplete: {
        crosswalk: [],
        name: @org_term,
        not_in_list: '0',
        user_entered_name: nil
      }
    }.with_indifferent_access

    @org_custom_params = {
      org_autocomplete: {
        crosswalk: [],
        name: 'Foo',
        not_in_list: '1',
        user_entered_name: Faker::Music::PearlJam.unique.album
      }
    }.with_indifferent_access

    @funder_selection_params = {
      org_autocomplete: {
        crosswalk: [],
        funder_name: @funder_term,
        funder_not_in_list: '0',
        funder_user_entered_name: nil
      }
    }.with_indifferent_access

    @funder_custom_params = {
      org_autocomplete: {
        crosswalk: [],
        funder_name: 'Foo',
        funder_not_in_list: '1',
        funder_user_entered_name: Faker::Music::PearlJam.unique.album
      }
    }.with_indifferent_access

    # Use a fake controller to test the concern
    # rubocop:disable Lint/ConstantDefinitionInBlock
    class FakeController < ApplicationController
      include OrgSelectable

      # The OrgSelectable concern tries to access Devise's current_user method, so stub it here
      attr_accessor :current_user

      # Build out the user's record
      lang = Language.all.last
      org = Org.create(name: 'Foo University', is_other: false, managed: true, language: lang,
                       institution: true)
      @current_user = ::User.create(email: 'foo@bar.edu', firstname: 'Foo', surname: 'Bar',
                                    password: SecureRandom.uuid, org: org, language: lang)
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock

    @controller = FakeController.new
  end

  after do
    # Make sure our FakeController class is destroyed!
    Object.send(:remove_const, :FakeController) if Object.const_defined?(:FakeController)
  end

  describe ':autocomplete_to_controller_params' do
    context 'Non-namespaced autocomplete' do
      context 'user selected an Org from the list' do
        before do
          Rails.configuration.x.application.restrict_orgs = false
          @controller.stubs(:org_selectable_params).returns(@org_selection_params)
        end

        it 'returns an empty hash if no name could be determined from the params' do
          @controller.expects(:name_from_params).returns(nil)
          expect(@controller.autocomplete_to_controller_params).to eql({})
        end

        it 'returns the :org_id that matches the id of the Org' do
          org = create(:org, :institution, name: @org_term.upcase, managed: true)
          expected = { org_id: org.id }
          expect(@controller.autocomplete_to_controller_params).to eql(expected)
        end

        it 'returns the :org_id that matches the vals of the RegistryOrg with an Org' do
          org = create(:org, :organisation, name: "Foo #{@org_term.upcase} bar", managed: true)
          create(:registry_org, name: @org_term, org_id: org.id)
          expected = { org_id: org.id }
          expect(@controller.autocomplete_to_controller_params).to eql(expected)
        end

        it 'returns the :org_attributes that matches the vals of the RegistryOrg' do
          registry_org = create(:registry_org, name: @org_term)
          expected = {
            org_attributes: {
              abbreviation: registry_org.acronyms.first.upcase,
              contact_email: Rails.configuration.x.organisation.helpdesk_email,
              contact_name: format(_('%{app_name} helpdesk'), app_name: ApplicationService.application_name),
              is_other: false,
              links: JSON.parse({ org: [{ link: registry_org.home_page, text: 'Home Page' }] }.to_json),
              managed: false,
              name: registry_org.name,
              org_type: 2,
              target_url: registry_org.home_page
            }
          }
          expect(@controller.autocomplete_to_controller_params).to eql(expected)
        end
      end

      context 'user provided a custom Org name' do
        before do
          @controller.stubs(:org_selectable_params).returns(@org_custom_params)
          @custom_name = @org_custom_params[:org_autocomplete][:user_entered_name]
        end

        it 'returns an empty hash if the :restrict_orgs config flag is false and user is not logged in' do
          @controller.expects(:name_from_params).returns(nil)
          expect(@controller.autocomplete_to_controller_params).to eql({})
        end

        it 'returns an empty hash if the :restrict_orgs config flag is false and user is logged in' do
          @controller.expects(:name_from_params).returns(nil)
          expect(@controller.autocomplete_to_controller_params).to eql({})
        end

        it 'returns the :org_attributes if the :restrict_orgs config flag is false and user is a super admin' do
          @controller.expects(:name_from_params).returns(nil)
          expect(@controller.autocomplete_to_controller_params).to eql({})
        end

        it 'returns an empty hash if no name could be determined from the params' do
          @controller.expects(:name_from_params).returns(nil)
          expect(@controller.autocomplete_to_controller_params).to eql({})
        end

        it 'returns the :org_id if the user provided name matches an Org' do
          org = create(:org, :institution, name: @custom_name, managed: true)
          expected = { org_id: org.id }
          expect(@controller.autocomplete_to_controller_params).to eql(expected)
        end

        it 'returns the :org_id if the user provided name matches a RegistryOrg with an Org' do
          org = create(:org, :organisation, name: "Foo #{@custom_name.upcase} bar", managed: true)
          create(:registry_org, name: @custom_name, org_id: org.id)
          expected = { org_id: org.id }
          expect(@controller.autocomplete_to_controller_params).to eql(expected)
        end

        it 'returns the :org_attributes if the user provided name matches a RegistryOrg' do
          registry_org = create(:registry_org, name: @custom_name, fundref_id: nil)
          expected = {
            org_attributes: {
              abbreviation: registry_org.acronyms.first.upcase,
              contact_email: Rails.configuration.x.organisation.helpdesk_email,
              contact_name: format(_('%{app_name} helpdesk'), app_name: ApplicationService.application_name),
              is_other: false,
              links: JSON.parse({ org: [{ link: registry_org.home_page, text: 'Home Page' }] }.to_json),
              managed: false,
              name: registry_org.name,
              org_type: 4,
              target_url: registry_org.home_page
            }
          }
          expect(@controller.autocomplete_to_controller_params).to eql(expected)
        end

        it 'returns the :org_attributes of a new Org' do
          expected = {
            org_attributes: {
              abbreviation: @custom_name.split.map(&:first).map(&:upcase).join,
              contact_email: Rails.configuration.x.organisation.helpdesk_email,
              contact_name: format(_('%{app_name} helpdesk'), app_name: ApplicationService.application_name),
              is_other: false,
              links: JSON.parse({ org: [] }.to_json),
              managed: false,
              name: @custom_name,
              org_type: 0,
              target_url: nil
            }
          }
          expect(@controller.autocomplete_to_controller_params).to eql(expected)
        end
      end
    end

    context 'Namespaced autocomplete - user selected an Org from the list' do
      before do
        Rails.configuration.x.application.restrict_orgs = false
        @controller.stubs(:org_selectable_params).returns(@funder_selection_params)
        @namespace = { namespace: 'funder_' }
      end

      it 'returns an empty hash if no name could be determined from the params' do
        @controller.expects(:name_from_params).returns(nil)
        expect(@controller.autocomplete_to_controller_params(**@namespace)).to eql({})
      end

      it 'returns the :org_id that matches the id of the Org' do
        funder = create(:org, :funder, name: @funder_term.upcase, managed: true)
        expected = { org_id: funder.id }
        expect(@controller.autocomplete_to_controller_params(**@namespace)).to eql(expected)
      end

      it 'returns the :org_id that matches the vals of the RegistryOrg with an Org' do
        funder = create(:org, :funder, name: "Foo #{@funder_term.upcase} bar", managed: true)
        create(:registry_org, name: @funder_term, org_id: funder.id)
        expected = { org_id: funder.id }
        expect(@controller.autocomplete_to_controller_params(**@namespace)).to eql(expected)
      end

      it 'returns the :org_attributes that matches the vals of the RegistryOrg' do
        registry_org = create(:registry_org, name: @funder_term)
        expected = {
          org_attributes: {
            abbreviation: registry_org.acronyms.first.upcase,
            contact_email: Rails.configuration.x.organisation.helpdesk_email,
            contact_name: format(_('%{app_name} helpdesk'), app_name: ApplicationService.application_name),
            is_other: false,
            links: JSON.parse({ org: [{ link: registry_org.home_page, text: 'Home Page' }] }.to_json),
            managed: false,
            name: registry_org.name,
            org_type: 2,
            target_url: registry_org.home_page
          }
        }
        expect(@controller.autocomplete_to_controller_params(**@namespace)).to eql(expected)
      end
    end

    context 'Namespaced autocomplete - user provided a custom Org name' do
      before(:each) do
        Rails.configuration.x.application.restrict_orgs = false
        @controller.stubs(:org_selectable_params).returns(@funder_custom_params)
        @custom_name = @funder_custom_params[:org_autocomplete][:funder_user_entered_name]
        @namespace = { namespace: 'funder_' }
      end

      it 'returns an empty hash if the :restrict_orgs config flag is false and user is not logged in' do
        @controller.expects(:name_from_params).returns(nil)
        expect(@controller.autocomplete_to_controller_params(**@namespace)).to eql({})
      end

      it 'returns an empty hash if the :restrict_orgs config flag is false and user is logged in' do
        @controller.expects(:name_from_params).returns(nil)
        expect(@controller.autocomplete_to_controller_params(**@namespace)).to eql({})
      end

      it 'returns the :org_attributes if the :restrict_orgs config flag is false and user is a super admin' do
        @controller.expects(:name_from_params).returns(nil)
        expect(@controller.autocomplete_to_controller_params(**@namespace)).to eql({})
      end

      it 'returns an empty hash if no name could be determined from the params' do
        @controller.expects(:name_from_params).returns(nil)
        expect(@controller.autocomplete_to_controller_params(**@namespace)).to eql({})
      end

      it 'returns the :org_id if the user provided name matches an Org' do
        org = create(:org, :institution, name: @custom_name, managed: true, funder: true)
        expected = { org_id: org.id }
        expect(@controller.autocomplete_to_controller_params(**@namespace)).to eql(expected)
      end

      it 'returns the :org_id if the user provided name matches a RegistryOrg with an Org' do
        org = create(:org, :organisation, name: "Foo #{@custom_name.upcase} bar",
                                          managed: true, funder: true)
        create(:registry_org, name: @custom_name, org_id: org.id)
        expected = { org_id: org.id }
        expect(@controller.autocomplete_to_controller_params(**@namespace)).to eql(expected)
      end

      it 'returns the :org_attributes if the user provided name matches a RegistryOrg' do
        registry_org = create(:registry_org, name: @custom_name)
        expected = {
          org_attributes: {
            abbreviation: registry_org.acronyms.first.upcase,
            contact_email: Rails.configuration.x.organisation.helpdesk_email,
            contact_name: format(_('%{app_name} helpdesk'), app_name: ApplicationService.application_name),
            is_other: false,
            links: JSON.parse({ org: [{ link: registry_org.home_page, text: 'Home Page' }] }.to_json),
            managed: false,
            name: registry_org.name,
            org_type: 2,
            target_url: registry_org.home_page
          }
        }
        expect(@controller.autocomplete_to_controller_params(**@namespace)).to eql(expected)
      end

      it 'returns the :org_attributes of a new Org' do
        expected = {
          org_attributes: {
            abbreviation: @custom_name.split.map(&:first).map(&:upcase).join,
            contact_email: Rails.configuration.x.organisation.helpdesk_email,
            contact_name: format(_('%{app_name} helpdesk'), app_name: ApplicationService.application_name),
            is_other: false,
            links: JSON.parse({ org: [] }.to_json),
            managed: false,
            name: @custom_name,
            org_type: 2,
            target_url: nil
          }
        }
        expect(@controller.autocomplete_to_controller_params(**@namespace)).to eql(expected)
      end
    end
  end

  describe ':process_org!(namespace: nil)' do
    context 'non-namespaced autocomplete' do
      before do
        Rails.configuration.x.application.restrict_orgs = false
        @user = create(:user, org: create(:org))
      end

      it 'returns nil if no :name_from_params does not return a name' do
        @controller.stubs(:name_from_params).returns(nil)
        expect(@controller.process_org!(user: @user)).to be_nil
      end

      context 'Existing Org' do
        it 'returns the existing Org' do
          org = create(:org, name: @org_term)
          @controller.stubs(:org_selectable_params).returns(@org_selection_params)
          expect(@controller.process_org!(user: @user)).to eql(org)
        end

        it 'returns nil if the existing Org if it is not :managed and we restrict that' do
          @controller.stubs(:org_selectable_params).returns(@org_selection_params)
          create(:org, name: @org_term, managed: false)
          expect(@controller.process_org!(user: @user, managed_only: true)).to be_nil
        end

        it 'returns nil if the Org does not already exist and the config has restrict_orgs set' do
          @controller.stubs(:org_selectable_params).returns(@org_selection_params)
          Rails.configuration.x.application.restrict_orgs = false
          expect(@controller.process_org!(user: @user)).to be_nil
        end
      end

      context 'Existing RegistryOrg' do
        it 'return the Org associated with the matching RegistryOrg' do
          org = create(:org)
          create(:registry_org, org: org, name: @org_term)
          @controller.stubs(:org_selectable_params).returns(@org_selection_params)
          expect(@controller.process_org!(user: @user)).to eql(org)
        end

        it 'returns nil if the config has restrict_orgs set' do
          Rails.configuration.x.application.restrict_orgs = true
          create(:registry_org, name: @org_term)
          @controller.stubs(:org_selectable_params).returns(@org_selection_params)
          expect(@controller.process_org!(user: @user)).to be_nil
        end

        it 'returns nil if the config has restrict_orgs not set but we only want managed' do
          Rails.configuration.x.application.restrict_orgs = false
          create(:registry_org, name: @org_term)
          @controller.stubs(:org_selectable_params).returns(@org_selection_params)
          expect(@controller.process_org!(user: @user, managed_only: true)).to be_nil
        end

        it 'derives a new Org from the matched RegistryOrg if restrict_orgs is set but user is SuperAdmin' do
          Rails.configuration.x.application.restrict_orgs = true
          super_admin = create(:user, :super_admin)
          registry_org = create(:registry_org, name: @org_term)
          @controller.stubs(:org_selectable_params).returns(@org_selection_params)
          org = @controller.process_org!(user: super_admin)
          expect(org.name).to eql(registry_org.name)
        end

        it 'derives an Org from the RegistryOrg if restrict_orgs is not set' do
          registry_org = create(:registry_org, name: @org_term)
          @controller.stubs(:org_selectable_params).returns(@org_selection_params)
          org = @controller.process_org!(user: @user)
          expect(org.name).to eql(registry_org.name)
        end
      end

      context 'Creates a new Org based on the name provided by the User' do
        it 'returns nil if the user was not providing a custom Org name' do
          @org_custom_params[:org_autocomplete][:not_in_list] = '0'
          @controller.stubs(:org_selectable_params).returns(@org_custom_params)
          expect(@controller.process_org!(user: @user)).to be_nil
        end

        it 'creates a new Org if no matches were found and this is allowed' do
          @controller.stubs(:org_selectable_params).returns(@org_custom_params)
          org = @controller.process_org!(user: @user)
          expect(org.name).to eql(@org_custom_params[:org_autocomplete][:user_entered_name])
        end
      end
    end

    context 'namespaced autocomplete' do
      before do
        @user = create(:user, org: create(:org))
      end

      it 'returns nil if no :name_from_params does not return a name' do
        Rails.configuration.x.application.restrict_orgs = false
        @controller.stubs(:name_from_params).returns(nil)
        expect(@controller.process_org!(user: @user, namespace: 'funder')).to be_nil
      end

      context 'Existing Org' do
        it 'returns the existing Org' do
          Rails.configuration.x.application.restrict_orgs = false
          org = create(:org, name: @funder_term)
          @controller.stubs(:org_selectable_params).returns(@funder_selection_params)
          expect(@controller.process_org!(user: @user, namespace: 'funder')).to eql(org)
        end

        it 'returns nil if the existing Org if it is not :managed and we restrict that' do
          Rails.configuration.x.application.restrict_orgs = false
          @controller.stubs(:org_selectable_params).returns(@funder_selection_params)
          create(:org, name: @funder_term, managed: false)
          expect(@controller.process_org!(user: @user, managed_only: true, namespace: 'funder')).to be_nil
        end

        it 'returns nil if the Org does not already exist and the config has restrict_orgs set' do
          @controller.stubs(:org_selectable_params).returns(@funder_selection_params)
          Rails.configuration.x.application.restrict_orgs = false
          expect(@controller.process_org!(user: @user, namespace: 'funder')).to be_nil
        end
      end

      context 'Existing RegistryOrg' do
        it 'return the Org associated with the matching RegistryOrg' do
          Rails.configuration.x.application.restrict_orgs = false
          org = create(:org)
          create(:registry_org, org: org, name: @funder_term)
          @controller.stubs(:org_selectable_params).returns(@funder_selection_params)
          expect(@controller.process_org!(user: @user, namespace: 'funder')).to eql(org)
        end

        it 'returns nil if the config has restrict_orgs set' do
          Rails.configuration.x.application.restrict_orgs = true
          create(:registry_org, name: @funder_term)
          @controller.stubs(:org_selectable_params).returns(@funder_selection_params)
          expect(@controller.process_org!(user: @user, namespace: 'funder')).to be_nil
        end

        it 'returns nil if the config has restrict_orgs not set but we only want managed' do
          Rails.configuration.x.application.restrict_orgs = false
          create(:registry_org, name: @funder_term)
          @controller.stubs(:org_selectable_params).returns(@funder_selection_params)
          expect(@controller.process_org!(user: @user, managed_only: true, namespace: 'funder')).to be_nil
        end

        it 'derives a new Org from the matched RegistryOrg if restrict_orgs is set but user is SuperAdmin' do
          Rails.configuration.x.application.restrict_orgs = true
          super_admin = create(:user, :super_admin)
          registry_org = create(:registry_org, name: @funder_term)
          @controller.stubs(:org_selectable_params).returns(@funder_selection_params)
          org = @controller.process_org!(user: super_admin, namespace: 'funder')
          expect(org.name).to eql(registry_org.name)
        end

        it 'derives an Org from the RegistryOrg if restrict_orgs is not set' do
          Rails.configuration.x.application.restrict_orgs = false
          registry_org = create(:registry_org, name: @funder_term)
          @controller.stubs(:org_selectable_params).returns(@funder_selection_params)
          org = @controller.process_org!(user: @user, namespace: 'funder')
          expect(org.name).to eql(registry_org.name)
        end
      end

      context 'Creates a new Org based on the name provided by the User' do
        it 'returns nil if the user was not providing a custom Org name' do
          Rails.configuration.x.application.restrict_orgs = false
          @funder_custom_params[:org_autocomplete][:funder_not_in_list] = '0'
          @controller.stubs(:org_selectable_params).returns(@funder_custom_params)
          expect(@controller.process_org!(user: @use, namespace: 'funder')).to be_nil
        end

        it 'creates a new Org if no matches were found and this is allowed' do
          Rails.configuration.x.application.restrict_orgs = false
          @controller.stubs(:org_selectable_params).returns(@funder_custom_params)
          org = @controller.process_org!(user: @user, namespace: 'funder')
          expect(org.name).to eql(@funder_custom_params[:org_autocomplete][:funder_user_entered_name])
        end
      end
    end
  end

  context 'private methods' do
    describe ':name_from_params(namespace:)' do
      it 'returns an empty string if no names are available' do
        @controller.stubs(:org_selectable_params).returns({})
        expect(@controller.send(:name_from_params)).to be_nil
      end

      it 'returns an empty string if a namespace is provided but no names are available' do
        @controller.stubs(:org_selectable_params).returns({})
        expect(@controller.send(:name_from_params, namespace: 'funder')).to be_nil
      end

      it 'returns the user entered name if no namespace is provided' do
        @controller.stubs(:org_selectable_params).returns(@org_custom_params)
        expected = @org_custom_params[:org_autocomplete][:user_entered_name]
        expect(@controller.send(:name_from_params)).to eql(expected)
      end

      it 'returns the selected Org name if no namespace is provided' do
        @controller.stubs(:org_selectable_params).returns(@org_selection_params)
        expected = @org_selection_params[:org_autocomplete][:name]
        expect(@controller.send(:name_from_params)).to eql(expected)
      end

      it 'can handle a namespace that ends with an underscore (e.g. "funder_")' do
        @controller.stubs(:org_selectable_params).returns(@funder_selection_params)
        expected = @funder_selection_params[:org_autocomplete][:funder_name]
        expect(@controller.send(:name_from_params, namespace: 'funder_')).to eql(expected)
      end

      it 'returns the user entered name if namespace is provided' do
        @controller.stubs(:org_selectable_params).returns(@funder_custom_params)
        expected = @funder_custom_params[:org_autocomplete][:funder_user_entered_name]
        expect(@controller.send(:name_from_params, namespace: 'funder')).to eql(expected)
      end

      it 'returns the selected Org name if namespace is provided' do
        @controller.stubs(:org_selectable_params).returns(@funder_selection_params)
        expected = @funder_selection_params[:org_autocomplete][:funder_name]
        expect(@controller.send(:name_from_params, namespace: 'funder')).to eql(expected)
      end
    end

    describe 'in_list?(namespace: nil)' do
      it 'returns false if :not_in_list == "1" and :namespace is not provided' do
        @controller.stubs(:org_selectable_params).returns(@org_custom_params)
        expect(@controller.send(:in_list?)).to be(false)
      end

      it 'returns true if :not_in_list != "1" and :namespace is not provided' do
        @controller.stubs(:org_selectable_params).returns(@org_selection_params)
        expect(@controller.send(:in_list?)).to be(true)
      end

      it 'returns false if :namespace_not_in_list == "1" and :namespace is provided' do
        @controller.stubs(:org_selectable_params).returns(@funder_custom_params)
        expect(@controller.send(:in_list?, namespace: 'funder')).to be(false)
      end

      it 'returns true if :namespace_not_in_list != "1" and :namespace is provided' do
        @controller.stubs(:org_selectable_params).returns(@funder_selection_params)
        expect(@controller.send(:in_list?, namespace: 'funder')).to be(true)
      end

      it 'can handle a namespace that ends with an underscore (e.g. "funder_")' do
        @controller.stubs(:org_selectable_params).returns(@funder_selection_params)
        expect(@controller.send(:in_list?, namespace: 'funder_')).to be(true)
      end
    end

    describe 'org_to_attributes(org:)' do
      before do
        @org = build(:org)
        @expected = {
          org_attributes: {
            name: @org.name,
            abbreviation: @org.abbreviation,
            contact_email: @org.contact_email,
            contact_name: @org.contact_name,
            links: @org.links || { org: [] },
            target_url: @org.target_url,
            is_other: @org.is_other?,
            managed: @org.managed?,
            org_type: @org.org_type
          }
        }
      end

      it 'returns an empty hash if :org is not an Org' do
        expect(@controller.send(:org_to_attributes, org: build(:plan))).to eql({})
      end

      it 'returns the Org as a hash of attributes' do
        expect(@controller.send(:org_to_attributes, org: @org)).to eql(@expected)
      end

      it 'uses the org.name_to_abbreviation if org.abbreviation is nil' do
        @org.abbreviation = nil
        result = @controller.send(:org_to_attributes, org: @org)[:org_attributes]
        expect(result[:abbreviation]).to eql(@org.name_to_abbreviation)
      end

      it 'uses the :helpdesk_email if org.contact_email is nil' do
        @org.contact_email = nil
        result = @controller.send(:org_to_attributes, org: @org)[:org_attributes]
        expect(result[:contact_email]).to eql(Rails.configuration.x.organisation.helpdesk_email)
      end

      it 'uses the Application name if org.contact_name is nil' do
        @org.contact_name = nil
        result = @controller.send(:org_to_attributes, org: @org)[:org_attributes]
        expect(result[:contact_name]).to eql(format(_('%{app_name} helpdesk'),
                                                    app_name: ApplicationService.application_name))
      end
    end

    describe ':create_org!(name:)' do
      it 'just returns the Org if it already exists' do
        org = create(:org)
        expect(@controller.send(:create_org!, name: org.name)).to eql(org)
      end

      it 'creates a new Org' do
        contact_email = Faker::Internet.email
        app = Faker::Lorem.word
        Rails.configuration.x.organisation.helpdesk_email = contact_email
        Rails.configuration.x.application.name = app

        new_name = Faker::Movies::StarWars.unique.character.split.last
        result = @controller.send(:create_org!, name: new_name)
        expect(result.new_record?).to be(false)
        expect(result.name).to eql(new_name)

        expect(result.abbreviation).to eql(Org.name_to_abbreviation(name: new_name))
        expect(result.contact_email).to eql(contact_email)
        expect(result.contact_name).to eql("#{app} helpdesk")
        expect(result.is_other).to be(false)
        expect(result.managed).to be(false)
        expect(result.organisation).to be(true)
        expect(result.funder).to be(false)
        expect(result.institution).to be(false)
      end
    end
  end
end
