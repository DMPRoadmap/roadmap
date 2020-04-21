# frozen_string_literal: true

require "rails_helper"

describe "api/v1/error.json.jbuilder" do

  before(:each) do
    @url = Faker::Internet.url
    @code = [200, 400, 404, 500].sample
    @errors = [Faker::Lorem.sentence, Faker::Lorem.sentence]

    assign :payload, { errors: @errors }

    @resp = OpenStruct.new(status: @code)
    @req = Net::HTTPGenericRequest.new("GET", nil, nil, @url)

    render template: "api/v1/error", locals: { response: @resp, request: @req }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe "error responses from controllers" do

    it "renders the standard_response partial" do
      expect(response).to render_template(partial: "api/v1/_standard_response")
    end

    it ":items is an empty array" do
      expect(@json[:items]).to eql([])
    end

    it ":errors contains an array of error messages" do
      expect(@json[:errors]).to eql(@errors)
    end

  end

end
