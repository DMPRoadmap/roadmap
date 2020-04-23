# frozen_string_literal: true

require "rails_helper"

describe "api/v1/identifiers/_show.json.jbuilder" do

  before(:each) do
    @scheme = create(:identifier_scheme)
    @identifier = create(:identifier, value: Faker::Lorem.word,
                                      identifier_scheme: @scheme)
    render partial: "api/v1/identifiers/show", locals: { identifier: @identifier }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe "includes all of the identifier attributes" do
    it "includes :type" do
      expect(@json[:type]).to eql(@identifier.identifier_format)
    end
    it "includes :identifier" do
      expect(@json[:identifier]).to eql(@identifier.value)
    end
  end

end
