# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrgSelection::HashToOrgService do

  before(:each) do
    @name = Faker::Lorem.company.name
    @abbrev = Faker::Lorem.word.upcase
    @lang = create(:language)
    @url = Faker::Internet.url
    @attr_key = Faker::Lorem.word
    @attr_val = Faker::Lorem.word

    @hash = {
      name: "#{@name} (#{abbrev})", sort_name: @name,
      score: Faker::number.number, weight: Faker::number.number,
      language: @lang.abbreviation, url: @url,
      "@attr_key": @attr_val
    }
  end

  describe "#to_org(hash:)" do

  end

  describe "#to_identifiers(hash:)" do

  end

  context "private methods" do
    describe "#initialize_org(hash:)" do

    end
    describe "#links_from_hash(name:, website:)" do

    end
    describe "#abbreviation_from_hash(hash:)" do

    end
    describe "#language_from_hash(hash:)" do

    end
    describe "#identifier_keys" do

    end
    describe "#attr_keys(hash:)" do

    end
    describe "#exact_match?(rec:, name2:)" do

    end
  end

end
