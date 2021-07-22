# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contributor, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:roles) }

    it "should validate that roles is greater than zero" do
      subject.name = Faker::Books::Dune.character
      subject.email = Faker::Internet.email
      is_expected.to validate_numericality_of(:roles)
        .with_message("You must specify at least one role.")
    end

    describe "#name_or_email_presence" do
      before(:each) do
        @contributor = build(:contributor, plan: create(:plan), investigation: true)
      end

      it "is invalid if both the name and email are blank" do
        @contributor.name = nil
        @contributor.email = nil
        expect(@contributor.valid?).to eql(false)
        expect(@contributor.errors[:name].present?).to eql(true)
        expect(@contributor.errors[:email].present?).to eql(true)
      end
      it "is valid if a name is present" do
        @contributor.email = nil
        expect(@contributor.valid?).to eql(true)
      end
      it "is valid if an email is present" do
        @contributor.name = nil
        expect(@contributor.valid?).to eql(true)
      end
    end

  end

  context "associations" do
    it { is_expected.to belong_to(:org).optional }
    it { is_expected.to belong_to(:plan).optional }
    it { is_expected.to have_many(:identifiers) }
  end

  describe "==(other)" do
    before(:each) do
      @contributor = build(:contributor)
    end

    it "returns false if :other is not a Contributor" do
      expect(@contributor == build(:org)).to eql(false)
    end
    it "returns false if the associated Plan's do not match" do
      expect(@contributor == create(:contributor, plan: create(:plan))).to eql(false)
    end
    it "returns false if the email or ORCID or name do not match" do
      contributor = build(:contributor)
      expect(@contributor == contributor).to eql(false)
    end
    it "returns true on an email match" do
      contributor = build(:contributor, email: @contributor.email)
      expect(@contributor == contributor).to eql(true)
    end
    it "returns true on a name match" do
      contributor = build(:contributor, name: @contributor.name)
      expect(@contributor == contributor).to eql(true)
    end
    it "returns true on an ORCID match" do
      scheme = create(:identifier_scheme, name: "orcid")
      orcid = build(:identifier, identifier_scheme: scheme)
      @contributor.identifiers << orcid
      contributor = build(:contributor, identifiers: [orcid])
      expect(@contributor == contributor).to eql(true)
    end
  end

  describe "merge(other)" do
    before(:each) do
      @scheme = create(:identifier_scheme, name: "orcid")
      @contributor = build(:contributor, org: build(:org), investigation: true)
      @contributor.identifiers << build(:identifier, identifier_scheme: @scheme)

      @new_contributor = build(:contributor, org: build(:org))
      @new_contributor.identifiers << build(:identifier, identifier_scheme: @scheme)
    end

    it "retains the existing values" do
      original = @contributor.clone
      @contributor = @contributor.merge(@new_contributor)
      expect(@contributor.org).to eql(original.org)
      expect(@contributor.email).to eql(original.email)
      expect(@contributor.name).to eql(original.name)
      expect(@contributor.phone).to eql(original.phone)
      expect(@contributor.investigation?).to eql(original.investigation?)
      expect(@contributor.data_curation?).to eql(original.data_curation?)
      expect(@contributor.project_administration?).to eql(original.project_administration?)
      expect(@contributor.identifiers.length).to eql(original.identifiers.length)
      expect(@contributor.identifiers.first.value).to eql(original.identifiers.first.value)
    end
    it "appends the :org" do
      @contributor.org = nil
      expect(@contributor.merge(@new_contributor).org).to eql(@new_contributor.org)
    end
    it "appends the :email" do
      @contributor.email = nil
      expect(@contributor.merge(@new_contributor).email).to eql(@new_contributor.email)
    end
    it "appends the :name" do
      @contributor.name = nil
      expect(@contributor.merge(@new_contributor).name).to eql(@new_contributor.name)
    end
    it "appends the :phone" do
      @contributor.phone = nil
      expect(@contributor.merge(@new_contributor).phone).to eql(@new_contributor.phone)
    end
    it "appends the identifiers" do
      @contributor.identifiers = [build(:identifier, identifier_scheme: nil)]
      results = @contributor.merge(@new_contributor).identifiers
      expect(results.length).to eql(2)
      expect(results.include?(@new_contributor.identifiers.first)).to eql(true)
    end
    it "appends the :investigation role" do
      @contributor.investigation = false
      @new_contributor.investigation = true
      expect(@contributor.merge(@new_contributor).investigation?).to eql(true)
    end
    it "appends the :data_curation role" do
      @contributor.data_curation = false
      @new_contributor.data_curation = true
      expect(@contributor.merge(@new_contributor).data_curation?).to eql(true)
    end
    it "appends the :project_administration role" do
      @contributor.project_administration = false
      @new_contributor.project_administration = true
      expect(@contributor.merge(@new_contributor).project_administration?).to eql(true)
    end
  end

end
