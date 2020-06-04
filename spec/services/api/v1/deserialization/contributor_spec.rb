# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Deserialization::Contributor do

  before(:each) do
    # Org requires a language, so make sure a default is available!
    create(:language, default_language: true) unless Language.default
    @org = create(:org)
    @plan = create(:plan, template: create(:template), org: @org)

    @name = Faker::Movies::StarWars.character
    @email = Faker::Internet.email

    @contributor = create(:contributor, org: @org, plan: @plan,
                                        name: @name, email: @email)
    @role = "#{Contributor::ONTOLOGY_BASE_URL}/#{@contributor.selected_roles.first}"

    @scheme = create(:identifier_scheme)
    @identifier = create(:identifier, identifiable: @contributor,
                                      identifier_scheme: @scheme,
                                      value: SecureRandom.uuid)
    @contributor.reload
    @json = { name: @name, mbox: @email, role: [@role] }
  end

  describe "#deserialize!(json: {})" do
    before(:each) do
      described_class.stubs(:marshal_contributor).returns(@contributor)
    end

    it "returns nil if json is not valid" do
      expect(described_class.deserialize!(plan_id: @plan.id, json: nil)).to eql(nil)
    end
    it "returns nil if the Contributor is not valid" do
      Contributor.any_instance.stubs(:valid?).returns(false)
      expect(described_class.deserialize!(plan_id: @plan.id, json: @json)).to eql(nil)
    end
    it "calls attach_identifier!" do
      described_class.expects(:attach_identifier!).at_least(1)
      id = SecureRandom.uuid
      scheme = create(:identifier_scheme, identifier_prefix: nil)
      json = @json.merge(
        { contributor_id: { type: scheme.name.downcase, identifier: id } }
      )
      described_class.deserialize!(plan_id: @plan.id, json: json)
    end
    it "returns the Contributor" do
      result = described_class.deserialize!(plan_id: @plan.id, json: @json)
      expect(result).to eql(@contributor)
    end
  end

  context "private methods" do

    describe "#valid?(is_contact:, json:)" do
      it "returns false if json is not present" do
        result = described_class.send(:valid?, is_contact: true, json: nil)
        expect(result).to eql(false)
      end
      it "returns false if :name and :mbox are not present" do
        json = { role: [@role] }
        result = described_class.send(:valid?, is_contact: true, json: json)
        expect(result).to eql(false)
      end
      context "Contact" do
        it "returns true without :role" do
          json = { name: @name, mbox: @email }
          result = described_class.send(:valid?, is_contact: true, json: json)
          expect(result).to eql(true)
        end
        it "returns true with :role" do
          result = described_class.send(:valid?, is_contact: true, json: @json)
          expect(result).to eql(true)
        end
      end
      context "Contributor" do
        it "returns false without :role" do
          json = { name: @name, mbox: @email }
          result = described_class.send(:valid?, is_contact: false, json: json)
          expect(result).to eql(false)
        end
        it "returns true with :role" do
          result = described_class.send(:valid?, is_contact: false, json: @json)
          expect(result).to eql(true)
        end
      end
    end

    describe "#marshal_contributor(plan_id:, is_contact:, json:)" do
      it "returns nil if the plan_id is not present" do
        result = described_class.send(:marshal_contributor, plan_id: nil,
                                                            is_contact: true,
                                                            json: @json)
        expect(result).to eql(nil)
      end
      it "returns nil if the json is not present" do
        result = described_class.send(:marshal_contributor, plan_id: @plan.id,
                                                            is_contact: true,
                                                            json: nil)
        expect(result).to eql(nil)
      end
      it "attaches the Org to the Contributor" do
        result = described_class.send(:marshal_contributor, plan_id: @plan.id,
                                                            is_contact: true,
                                                            json: @json)
        expect(result.org).to eql(@org)
      end
      it "assigns the contact role" do
        json = { name: Faker::TvShows::Simpsons.character }
        result = described_class.send(:marshal_contributor, plan_id: @plan.id,
                                                            is_contact: true,
                                                            json: json)
        expect(result.data_curation?).to eql(true)
      end
      it "assigns the contributor role" do
        role = @contributor.all_roles[1].to_s
        json = { name: Faker::TvShows::Simpsons.character, role: [role] }
        result = described_class.send(:marshal_contributor, plan_id: @plan.id,
                                                            is_contact: false,
                                                            json: json)
        expect(result.send(:"#{role}?")).to eql(true)
      end
    end

    describe "#find_by_identifier(json:)" do
      it "returns nil if json is not present" do
        expect(described_class.send(:find_by_identifier, json: nil)).to eql(nil)
      end
      it "returns nil if :contact_id and :contributor_id are not present" do
        expect(described_class.send(:find_by_identifier, json: @json)).to eql(nil)
      end
      it "finds the Contributor by :contact_id" do
        json = @json.merge(
          { contact_id: { type: @scheme.name, identifier: @identifier.value } }
        )
        result = described_class.send(:find_by_identifier, json: json)
        expect(result).to eql(@contributor)
      end
      it "finds the Contributor by :contributor_id" do
        json = @json.merge(
          { contributor_id: { type: @scheme.name, identifier: @identifier.value } }
        )
        result = described_class.send(:find_by_identifier, json: json)
        expect(result).to eql(@contributor)
      end
      it "returns nil if no Contributor was found" do
        json = @json.merge(
          { contributor_id: { type: @scheme.name, identifier: SecureRandom.uuid } }
        )
        expect(described_class.send(:find_by_identifier, json: json)).to eql(nil)
      end
    end

    describe "#find_or_initialize_by(plan_id:, json:)" do
      it "returns nil if json is not present" do
        result = described_class.send(:find_or_initialize_by, plan_id: @plan.id,
                                                              json: nil)
        expect(result).to eql(nil)
      end
      it "returns nil if plan_id is not present" do
        result = described_class.send(:find_or_initialize_by, plan_id: nil,
                                                              json: @json)
        expect(result).to eql(nil)
      end
      it "finds the matching Contributor" do
        result = described_class.send(:find_or_initialize_by, plan_id: @plan.id,
                                                              json: @json)
        expect(result).to eql(@contributor)
      end
      it "initializes the Contributor if there were no viable matches" do
        json = {
          name: Faker::TvShows::Simpsons.character,
          mbox: Faker::Internet.unique.email
        }
        result = described_class.send(:find_or_initialize_by, plan_id: @plan.id,
                                                              json: json)
        expect(result.new_record?).to eql(true)
        expect(result.name).to eql(json[:name])
        expect(result.email).to eql(json[:mbox])
      end
    end

    describe "#deserialize_org(json:)" do
      it "returns nil if json is not present" do
        expect(described_class.send(:deserialize_org, json: nil)).to eql(nil)
      end
      it "returns nil if json :affiliation is not present" do
        expect(described_class.send(:deserialize_org, json: @json)).to eql(nil)
      end
      it "calls the Org.deserialize! method" do
        Api::V1::Deserialization::Org.expects(:deserialize!).at_least(1)
        json = @json.merge({ affiliation: { name: Faker::Company.name } })
        described_class.send(:deserialize_org, json: json)
      end
    end

    describe "#assign_contact_roles(contributor:)" do
      it "returns nil if the contributor is not present" do
        result = described_class.send(:assign_contact_roles, contributor: nil)
        expect(result).to eql(nil)
      end
      it "assigns the :data_curation role" do
        result = described_class.send(:assign_contact_roles, contributor: @contributor)
        expect(result.data_curation?).to eql(true)
      end
    end

    describe "#assign_roles(contributor:, json:)" do
      it "returns nil if the contributor is not present" do
        result = described_class.send(:assign_roles, contributor: nil, json: @json)
        expect(result).to eql(nil)
      end
      it "returns the Contributor as-is if json is not present" do
        result = described_class.send(:assign_roles, contributor: @contributor,
                                                     json: nil)
        expect(result).to eql(@contributor)
      end
      it "returns the Contributor as-is if json :role is not present" do
        json = { name: @name }
        result = described_class.send(:assign_roles, contributor: @contributor,
                                                     json: json)
        expect(result).to eql(@contributor)
      end
      it "ignores unknown/undefined roles" do
        @json[:role] << Faker::Lorem.word
        result = described_class.send(:assign_roles, contributor: @contributor,
                                                     json: @json)
        expect(result.selected_roles).to eql(@contributor.selected_roles)
      end
      it "calls the translate_role" do
        described_class.expects(:translate_role).at_least(1)
        described_class.send(:assign_roles, contributor: @contributor, json: @json)
      end
      it "assigns the roles" do
        result = described_class.send(:assign_roles, contributor: @contributor,
                                                     json: @json)
        expect(result.selected_roles).to eql(@contributor.selected_roles)
      end

    end

    describe "#attach_identifier!(contributor:, json:)" do
      it "returns the Contributor as-is if json is not present" do
        result = described_class.send(:attach_identifier!, contributor: @contributor,
                                                           json: nil)
        expect(result.identifiers).to eql(@contributor.identifiers)
      end
      it "returns the Contributor as-is if the json has no identifier" do
        result = described_class.send(:attach_identifier!, contributor: @contributor,
                                                           json: @json)
        expect(result.identifiers).to eql(@contributor.identifiers)
      end
      it "returns the Contributor as-is if it already has a :contributor_id" do
        json = @json.merge(
          { contributor_id: { type: @scheme.name, identifier: @identifier.value } }
        )
        result = described_class.send(:attach_identifier!, contributor: @contributor,
                                                           json: json)
        expect(result.identifiers).to eql(@contributor.identifiers)
      end
      it "returns the Contributor as-is if it already has the :contact_id" do
        json = @json.merge(
          { contact_id: { type: @scheme.name, identifier: @identifier.value } }
        )
        result = described_class.send(:attach_identifier!, contributor: @contributor,
                                                           json: json)
        expect(result.identifiers).to eql(@contributor.identifiers)
      end
      it "adds the :contributor_id to the Contributor" do
        scheme = create(:identifier_scheme, name: "foo")
        json = @json.merge(
          { contributor_id: { type: scheme.name, identifier: @identifier.value } }
        )
        result = described_class.send(:attach_identifier!, contributor: @contributor,
                                                           json: json)
        expect(result.identifiers.length > @contributor.identifiers.length).to eql(false)
        expect(result.identifiers.last.identifier_scheme).to eql(scheme)
        id = result.identifiers.last.value
        expect(id.end_with?(@identifier.value)).to eql(true)
      end
      it "adds the :contact_id to the Contributor" do
        scheme = create(:identifier_scheme, name: "foo")
        json = @json.merge(
          { contact_id: { type: scheme.name, identifier: @identifier.value } }
        )
        result = described_class.send(:attach_identifier!, contributor: @contributor,
                                                           json: json)
        expect(result.identifiers.length > @contributor.identifiers.length).to eql(false)
        expect(result.identifiers.last.identifier_scheme).to eql(scheme)
        id = result.identifiers.last.value
        expect(id.end_with?(@identifier.value)).to eql(true)
      end
    end

    describe "#translate_role(role:)" do
      before(:each) do
        @default = Contributor.default_role
      end

      it "returns the default role if role is not present?" do
        expect(described_class.send(:translate_role, role: nil)).to eql(@default)
      end
      it "returns the default role if role is not a valid/defined role" do
        result = described_class.send(:translate_role, role: Faker::Lorem.word)
        expect(result).to eql(@default)
      end
      it "returns the role (when it includes the ONTOLOGY_BASE_URL)" do
        expected = @role.split("/").last
        expect(described_class.send(:translate_role, role: @role)).to eql(expected)
      end
      it "returns the role (when it does not include the ONTOLOGY_BASE_URL)" do
        role = Contributor.new.all_roles.last.to_s
        expect(described_class.send(:translate_role, role: role)).to eql(role)
      end
    end

  end

end
