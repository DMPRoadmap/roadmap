# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiClient, type: :model do
  context 'validations' do
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
        .with_message('must be unique')
    }

    # Email format validation
    it {
      is_expected.to allow_values('one@example.com', 'foo-bar@ed.ac.uk')
        .for(:contact_email)
    }
    it {
      is_expected.not_to allow_values('example.com', 'foo bar@ed.ac.uk')
        .for(:contact_email)
    }
  end

  context 'Associations' do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to have_many(:subscriptions) }
    it { is_expected.to have_many(:access_tokens) }
  end

  context 'Instance Methods' do
    before(:each) do
      @client = build(:api_client)
    end

    it ':to_s should return the name' do
      expect(@client.to_s).to eql(@client.name)
    end

    it ':client_id should return the :uid' do
      expect(@client.client_id).to eql(@client.uid)
    end

    it ':client_secret should return the :secret' do
      expect(@client.client_secret).to eql(@client.secret)
    end

    it ':available_scopes should return all of the scopes defined for Doorkeeper' do
      Doorkeeper.config.stubs(:default_scopes).returns(%w[one two three])
      Doorkeeper.config.stubs(:optional_scopes).returns(%w[nine eight one])
      # Note that it should deduplicate the 'one' found in both arrays
      expect(@client.available_scopes).to eql(%w[one two three nine eight])
    end

    describe ':plans' do
      it 'returns an empty array if there are no subscriptions' do
        @client.save
        expect(@client.plans.empty?).to eql(true)
      end
      it 'returns the expected plans' do
        @client.save
        plan_a = create(:plan)
        plan_b = create(:plan)
        create(:subscription, plan: plan_a, subscriber: @client)
        create(:subscription, plan: plan_b, subscriber: @client)
        results = @client.reload.plans
        expect(results.length).to eql(2)
        expect(results.include?(plan_a)).to eql(true)
        expect(results.include?(plan_b)).to eql(true)
      end
    end

    it ':ensure_scopes attaches the available scopes before validation occurs' do
      Doorkeeper.config.stubs(:default_scopes).returns(%w[one two three])
      Doorkeeper.config.stubs(:optional_scopes).returns(%w[nine eight one])
      @client.scopes = nil
      @client.send(:ensure_scopes)
      # Note that it should sort them alphabetically
      expect(@client.scopes.to_s).to eql('eight nine one three two')
    end
  end
end
