# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ValidationService do

  describe "identifier_valid?(json:)" do
    it "returns `false` when json is not present" do
      expect(described_class.identifier_valid?(json: nil)).to eql(false)
    end
    it "returns `false` when json[:type] is not present" do
      json = { identifier: SecureRandom.uuid }
      expect(described_class.identifier_valid?(json: json)).to eql(false)
    end
    it "returns `false` when json[:identifier] is not present" do
      json = { type: Faker::Lorem.word }
      expect(described_class.identifier_valid?(json: json)).to eql(false)
    end
    it "returns `true` when valid" do
      json = { type: Faker::Lorem.word, identifier: SecureRandom.uuid }
      expect(described_class.identifier_valid?(json: json)).to eql(true)
    end
  end

  describe "org_valid?(json:)" do
    it "returns `false` when json is not present" do
      expect(described_class.org_valid?(json: nil)).to eql(false)
    end
    it "returns `false` when json[:name] is not present" do
      json = { abbreviation: Faker::Lorem.word.upcase }
      expect(described_class.org_valid?(json: json)).to eql(false)
    end
    it "returns `true` when valid" do
      json = { name: Faker::Company.unique.name }
      expect(described_class.org_valid?(json: json)).to eql(true)
    end
  end

  describe "contributor_valid?(json:, is_contact: false)" do
    it "returns `false` when json is not present" do
      expect(described_class.contributor_valid?(json: nil)).to eql(false)
    end
    it "returns `false` when json[:name] or json[:mbox] is not present" do
      json = { contributor_id: { type: Faker::Lorem.word, identifier: SecureRandom.uuid } }
      expect(described_class.contributor_valid?(json: json)).to eql(false)
    end
    it "returns `false` when json[:role] is not present and :is_contact is false" do
      json = { name: Faker::Music::PearlJam.musician, mbox: Faker::Internet.email }
      expect(described_class.contributor_valid?(json: json)).to eql(false)
    end
    it "returns `true` when valid and :is_contact is false" do
      json = { name: Faker::Music::PearlJam.musician, role: Faker::Lorem.word }
      expect(described_class.contributor_valid?(json: json)).to eql(true)
      json = { mbox: Faker::Internet.email, role: Faker::Lorem.word }
      expect(described_class.contributor_valid?(json: json)).to eql(true)
    end
    it "returns `true` when valid and :is_contact is true" do
      json = { name: Faker::Music::PearlJam.musician }
      expect(described_class.contributor_valid?(json: json, is_contact: true)).to eql(true)
      json = { mbox: Faker::Internet.email }
      expect(described_class.contributor_valid?(json: json, is_contact: true)).to eql(true)
    end
  end

  describe "funding_valid?(json:)" do
    it "returns `false` when json is not present" do
      expect(described_class.funding_valid?(json: nil)).to eql(false)
    end
    it "returns `false` when json[:name] or json[:funder_id] or json[:grant_id] are not present" do
      json = { status: Faker::Lorem.word }
      expect(described_class.funding_valid?(json: json)).to eql(false)
    end
    it "returns `true` when json[:name] is present" do
      json = { name: Faker::Company.name }
      expect(described_class.funding_valid?(json: json)).to eql(true)
    end
    it "returns `true` when json[:funder_id][:identifier] is present" do
      json = { funder_id: { identifier: SecureRandom.uuid } }
      expect(described_class.funding_valid?(json: json)).to eql(true)
    end
    it "returns `true` when json[:grant_id][:identifier] is present" do
      json = { grant_id: { identifier: SecureRandom.uuid } }
      expect(described_class.funding_valid?(json: json)).to eql(true)
    end
  end

  describe "dataset_valid?(json:)" do
    it "returns `false` when json is not present" do
      expect(described_class.dataset_valid?(json: nil)).to eql(false)
    end
  end

  describe "plan_valid?(json:)" do
    it "returns `false` when json is not present" do
      expect(described_class.plan_valid?(json: nil)).to eql(false)
    end
    it "returns `false` when json[:title] is not present" do
      json = { contact: { mbox: Faker::Internet.email } }
      expect(described_class.plan_valid?(json: json)).to eql(false)
    end
    it "returns `false` when json[:contact][:mbox] is not present" do
      json = { title: Faker::Lorem.sentence }
      expect(described_class.plan_valid?(json: json)).to eql(false)
    end
    it "returns `true` when json[:title] and json[:contact][:mbox] are present" do
      json = { title: Faker::Lorem.sentence, contact: { mbox: Faker::Internet.email } }
      expect(described_class.plan_valid?(json: json)).to eql(true)
    end
  end

end
