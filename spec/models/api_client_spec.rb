# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiClient, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:contact_email) }

    # Uniqueness validation
    it {
      subject.name = Faker::Lorem.word
      subject.contact_email = Faker::Internet.email
      subject.client_id = Faker::Lorem.word
      subject.client_secret = Faker::Lorem.word
      is_expected.to validate_uniqueness_of(:name)
        .case_insensitive
        .with_message("must be unique")
    }

    # Email format validation
    it {
      is_expected.to allow_values("one@example.com", "foo-bar@ed.ac.uk")
        .for(:contact_email)
    }
    it {
      is_expected.not_to allow_values("example.com", "foo bar@ed.ac.uk")
        .for(:contact_email)
    }

  end

  context "Associations" do
    it { is_expected.to belong_to :org }
    it { is_expected.to have_many :plans }
  end

  context "Instance Methods" do
    before(:each) do
      @client = build(:api_client)
    end

    describe "#to_s" do
      it "should return the name" do
        expect(@client.to_s).to eql(@client.name)
      end

      it "should return the name through interpolation" do
        expect("#{@client}").to eql(@client.name)
      end
    end

    describe "#authenticate" do
      it "returns false if no secret is specified" do
        expect(@client.authenticate(secret: nil)).to eql(false)
      end

      it "returns false if the secrets do not match" do
        expect(@client.authenticate(secret: SecureRandom.uuid)).to eql(false)
      end

      it "returns true if the secrets match" do
        expect(@client.authenticate(secret: @client.client_secret)).to eql(true)
      end
    end

  end

end
