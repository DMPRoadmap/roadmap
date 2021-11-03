# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrgSelectable do
  before(:each) do
<<<<<<< HEAD
    # Stub controller implementing the OrgSelectable concern
    class StubsController < ApplicationController
=======
    # rubocop:disable Lint/ConstantDefinitionInBlock
    class StubController < ApplicationController
>>>>>>> 9e252de5049794dcf2f990010936a13d613c6786
      include OrgSelectable
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock

    @search_term = Faker::Movies::StarWars.unique.character

    @matched_org = create(:org, name: "#{Faker::Lorem.word} (#{@search_term.upcase})", managed: true)
    @unmatched_org = create(:org, name: SecureRandom.uuid)

    @related_registry_org = create(:registry_org, name: @search_term, org_id: @matched_org.id)
    @unrelated_registry_org = create(:registry_org, name: "#{@search_term} (#{Faker::Internet.url})")
    @unmatched_registry_org = create(:org, name: SecureRandom.uuid)

    @controller = StubsController.new
  end

  after(:each) do
    # Drop the stub controller
    Object.send :remove_const, :StubsController
  end

<<<<<<< HEAD
  describe ":process_org!(namespace: nil)" do
    [nil, "funder"].each do |namespace|
      describe "namespace: #{namespace}" do
        before(:each) do
          @prefix = namespace.present? ? "#{namespace.downcase}_" : ""
          Rails.configuration.x.application.restrict_orgs = false
          @user = create(:user, org: @unmatched_org)
        end
        it "uses the :#{@prefix}user_entered_name if present" do
          stub_strong_params(namespace: namespace, name: "", not_in_list: "1",
                             user_entered_name: @matched_org.name)
          result = @controller.process_org!(user: @user, namespace: namespace)
          expect(result).to eql(@matched_org)
        end
        it "users the :#{@prefix}name if no :#{@prefix}user_entered_name is present" do
          stub_strong_params(namespace: namespace, name: @matched_org.name, not_in_list: "0",
                            user_entered_name: "")
          result = @controller.process_org!(user: @user, namespace: namespace)
          expect(result).to eql(@matched_org)
        end
        it "returns the Org if an Org is found" do
          stub_strong_params(namespace: namespace, name: @matched_org.name, not_in_list: "0",
                             user_entered_name: "")
          result = @controller.process_org!(user: @user, namespace: namespace)
          expect(result).to eql(@matched_org)
        end
        it "returns the Org created from the RegistryOrg if found" do
          stub_strong_params(namespace: namespace, name: @unrelated_registry_org.name,
                             not_in_list: "0", user_entered_name: "")
          result = @controller.process_org!(user: @user, namespace: namespace)
          expect(result.name).to eql(@unrelated_registry_org.name)
        end
        it "returns nil if no Org or RegistryOrg matched and no :#{@prefix}user_entered_name is present" do
          stub_strong_params(namespace: namespace, name: SecureRandom.uuid,
                             not_in_list: "0", user_entered_name: "")
          result = @controller.process_org!(user: @user, namespace: namespace)
          expect(result).to eql(nil)
        end
        it "creates a new unmanaged Org based on #{@prefix}user_entered_name" do
          name = SecureRandom.uuid
          stub_strong_params(namespace: namespace, name: "", not_in_list: "1", user_entered_name: name)
          result = @controller.process_org!(user: @user, namespace: namespace)
          expect(result.name).to eql(name)
        end
        it "skips RegistryOrg search if restrict_orgs is set to true and user NOT a super admin" do
          Rails.configuration.x.application.restrict_orgs = true
          org_admin = create(:user, :org_admin, org: create(:org))

          stub_strong_params(namespace: namespace, name: @unrelated_registry_org.name,
                             not_in_list: "0", user_entered_name: "")
          result = @controller.process_org!(user: org_admin, namespace: namespace)
          expect(result).to eql(nil)
        end
        it "Performs RegistryOrg search if restrict_orgs is set to true and user is a super admin" do
          Rails.configuration.x.application.restrict_orgs = true
          super_admin = create(:user, :super_admin, org: create(:org))

          stub_strong_params(namespace: namespace, name: @unrelated_registry_org.name,
                             not_in_list: "0", user_entered_name: "")
          result = @controller.process_org!(user: super_admin, namespace: namespace)
          expect(result.name).to eql(@unrelated_registry_org.name)
        end
=======
  context 'private methods' do
    describe '#org_from_params(params:)' do
      it 'returns nil if params[:org_id] is not present' do
        expect(@controller.send(:org_from_params, params_in: {})).to eql(nil)
      end
      it 'returns nil if the params[:org_id] could not be converted' do
        @controller.stubs(:org_hash_from_params).returns({})
        expect(@controller.send(:org_from_params, params_in: {})).to eql(nil)
      end
      it 'returns an Org' do
        rslt = @controller.send(:org_from_params, params_in: @params)
        expect(rslt.is_a?(Org)).to eql(true)
>>>>>>> 9e252de5049794dcf2f990010936a13d613c6786
      end
    end
  end

<<<<<<< HEAD
  context "private methods" do

    describe ":create_org!(name:)" do
      it "just returns the Org if it already exists" do
        expect(@controller.send(:create_org!, name: @matched_org.name)).to eql(@matched_org)
      end

      it "creates a new Org" do
        contact_email = Faker::Internet.email
        app = Faker::Lorem.word
        Rails.configuration.x.organisation.helpdesk_email = contact_email
        Rails.configuration.x.application.name = app

        new_name = Faker::Movies::StarWars.unique.character
        result = @controller.send(:create_org!, name: new_name)
        expect(result.new_record?).to eql(false)
        expect(result.name).to eql(new_name)
        expect(result.abbreviation).to eql(Org.name_to_abbreviation(name: new_name))
        expect(result.contact_email).to eql(contact_email)
        expect(result.contact_name).to eql("#{app} helpdesk")
        expect(result.is_other).to eql(false)
        expect(result.managed).to eql(false)
        expect(result.organisation).to eql(true)
        expect(result.funder).to eql(false)
        expect(result.institution).to eql(false)
      end
    end

    describe "create_org_from_registry_org!(registry_org:)" do
      it "returns nil unless :registry_org is a RegistryOrg" do
        expect(@controller.send(:create_org_from_registry_org!, registry_org: Org.new)).to eql(nil)
      end
      it "it returns the associated Org if :registry_org already has one" do
        result = @controller.send(:create_org_from_registry_org!, registry_org: @related_registry_org)
        expect(result).to eql(@matched_org)
      end
      it "it calls RegistryOrg's to_org method" do
        @unrelated_registry_org.stubs(:to_org).returns(build(:org))
        @controller.send(:create_org_from_registry_org!, registry_org: @unrelated_registry_org)
      end
      it "creates the Org" do
        result = @controller.send(:create_org_from_registry_org!, registry_org: @unrelated_registry_org)
        expect(result.is_a?(Org)).to eql(true)
        expect(result.name).to eql(@unrelated_registry_org.name)
      end
      it "attaches the fundref_id and ror_id as Identifiers" do
        fundref = create(:identifier_scheme, name: "fundref", identifier_prefix: "https://fundref.org/")
        ror = create(:identifier_scheme, name: "ror", identifier_prefix: "https://ror.org/")
        @unrelated_registry_org.fundref_id = SecureRandom.uuid
        @unrelated_registry_org.ror_id = "#{ror.identifier_prefix}#{SecureRandom.uuid}"

        result = @controller.send(:create_org_from_registry_org!, registry_org: @unrelated_registry_org)
        expect(result.identifiers.length).to eql(2)

        fundref_id = result.identifiers.select { |id| id.identifier_scheme == fundref }.first
        ror_id = result.identifiers.select { |id| id.identifier_scheme == ror }.first
        expect(fundref_id.value).to eql("#{fundref.identifier_prefix}#{@unrelated_registry_org.fundref_id}")
        expect(ror_id.value).to eql(@unrelated_registry_org.ror_id)
      end
      it "sets the original :registry_org :org_id to the id of the new Org" do
        result = @controller.send(:create_org_from_registry_org!, registry_org: @unrelated_registry_org)
        @unrelated_registry_org.reload
        expect(result.id).to eql(@unrelated_registry_org.org_id)
=======
    describe '#identifiers_from_params(params:)' do
      it 'returns an empty array if params[:org_id] is not present' do
        rslt = @controller.send(:identifiers_from_params, params_in: {})
        expect(rslt).to eql([])
      end
      it 'returns an empty array if params[:org_id] could not be converted' do
        @controller.stubs(:org_hash_from_params).returns({})
        rslt = @controller.send(:identifiers_from_params, params_in: {})
        expect(rslt).to eql([])
      end
      it 'returns an Array of identifiers' do
        rslt = @controller.send(:identifiers_from_params, params_in: @params)
        expect(rslt.is_a?(Array)).to eql(true)
        expect(rslt.first.is_a?(Identifier)).to eql(true)
      end
    end

    describe '#org_hash_from_params(params:)' do
      it 'returns an empty hash is there is a JSON parse error' do
        JSON.expects(:parse).raises(JSON::ParserError)
        rslt = @controller.send(:org_hash_from_params, params_in: @params)
        expect(rslt).to eql({})
      end
      it 'logs JSON parse error' do
        JSON.expects(:parse).raises(JSON::ParserError)
        Rails.logger.expects(:error).at_least(2)
        @controller.send(:org_hash_from_params, params_in: @params)
      end
      it 'returns the hash' do
        rslt = @controller.send(:org_hash_from_params, params_in: @params)
        expect(rslt).to eql(JSON.parse(@params[:org_id]))
      end
    end

    describe '#remove_org_selection_params(params:)' do
      before(:each) do
        @rslt = @controller.send(:remove_org_selection_params,
                                 params_in: @params)
      end
      it 'removes the org_selector params' do
        expect(@rslt[:org_id].present?).to eql(false)
        expect(@rslt[:org_name].present?).to eql(false)
        expect(@rslt[:org_sources].present?).to eql(false)
        expect(@rslt[:org_crosswalk].present?).to eql(false)
      end
      it 'does not remove other params' do
        expect(@rslt[:other_param].present?).to eql(true)
>>>>>>> 9e252de5049794dcf2f990010936a13d613c6786
      end
    end
  end
<<<<<<< HEAD

  def stub_strong_params(namespace:, name: "", not_in_list: "0", user_entered_name: "")
    @params = ActionController::Parameters.new({
      "#{[namespace&.downcase, "name"].compact.join("_")}": name.to_s,
      "#{[namespace&.downcase, "not_in_list"].compact.join("_")}": not_in_list.to_s,
      "#{[namespace&.downcase, "user_entered_name"].compact.join("_")}": user_entered_name.to_s
    })
    @controller.stubs(:org_selectable_params).returns(@params)
  end
=======
>>>>>>> 9e252de5049794dcf2f990010936a13d613c6786
end
