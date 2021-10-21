# frozen_string_literal: true

require "rails_helper"

describe "api/v1/contributors/_show.json.jbuilder" do

  before(:each) do
    @plan = create(:plan)
    scheme = create(:identifier_scheme, name: "orcid")
    @contact = create(:contributor, org: create(:org), plan: @plan, roles_count: 0,
                                    data_curation: true)
    @ident = create(:identifier, identifiable: @contact, value: Faker::Lorem.word,
                                 identifier_scheme: scheme)
    @contact.reload
  end

  describe "includes all of the Contributor attributes" do
    before(:each) do
      render partial: "api/v1/contributors/show", locals: { contributor: @contact }
      @json = JSON.parse(rendered).with_indifferent_access
    end

    it "includes the :name" do
      expect(@json[:name]).to eql(@contact.name)
    end
    it "includes the :mbox" do
      expect(@json[:mbox]).to eql(@contact.email)
    end

    it "includes the :role" do
      expect(@json[:role].first.ends_with?("data-curation")).to eql(true)
    end

    it "includes :affiliation" do
      expect(@json[:affiliation][:name]).to eql(@contact.org.name)
    end

    it "includes :contributor_id" do
      expect(@json[:contributor_id][:type]).to eql(@ident.identifier_format)
      expect(@json[:contributor_id][:identifier]).to eql(@ident.value)
    end
    it "ignores non-orcid identifiers :contributor_id" do
      scheme = create(:identifier_scheme, name: "shibboleth")
      create(:identifier, value: Faker::Lorem.word, identifiable: @contact,
                          identifier_scheme: scheme)
      @contact.reload
      expect(@json[:contributor_id][:type]).to eql(@ident.identifier_format)
      expect(@json[:contributor_id][:identifier]).to eql(@ident.value)
    end
  end

  describe "includes all of the Contact attributes" do
    before(:each) do
      render partial: "api/v1/contributors/show", locals: { contributor: @contact,
                                                            is_contact: true }
      @json = JSON.parse(rendered).with_indifferent_access
    end

    it "includes the :name" do
      expect(@json[:name]).to eql(@contact.name)
    end
    it "includes the :mbox" do
      expect(@json[:mbox]).to eql(@contact.email)
    end

    it "does NOT include the :role" do
      expect(@json[:role]).to eql(nil)
    end

    it "includes :affiliation" do
      expect(@json[:affiliation][:name]).to eql(@contact.org.name)
    end

    it "includes :contact_id" do
      expect(@json[:contact_id][:type]).to eql(@ident.identifier_format)
      expect(@json[:contact_id][:identifier]).to eql(@ident.value)
    end
    it "ignores non-orcid identifiers :contact_id" do
      scheme = create(:identifier_scheme, name: "shibboleth")
      create(:identifier, value: Faker::Lorem.word, identifiable: @contact,
                          identifier_scheme: scheme)
      @contact.reload
      expect(@json[:contact_id][:type]).to eql(@ident.identifier_format)
      expect(@json[:contact_id][:identifier]).to eql(@ident.value)
    end
  end

end
