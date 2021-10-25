# frozen_string_literal: true

require "rails_helper"

describe "api/v1/plans/_cost.json.jbuilder" do

  before(:each) do
    # TODO: Implement this once the Currency question and Cost theme are in place
    #       and the PlanPresenter is extracting the info
    @cost = {
      title: Faker::Lorem.sentence,
      description: Faker::Lorem.paragraph,
      currency_code: Faker::Currency.code,
      value: Faker::Number.decimal(l_digits: 2)
    }.with_indifferent_access

    render partial: "api/v1/plans/cost", locals: { cost: @cost }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe "includes all of the cost attributes" do
    it "includes :title" do
      expect(@json[:title]).to eql(@cost[:title])
    end
    it "includes :description" do
      expect(@json[:description]).to eql(@cost[:description])
    end
    it "includes :currency_code" do
      expect(@json[:currency_code]).to eql(@cost[:currency_code])
    end
    it "includes :value" do
      expect(@json[:value]).to eql(@cost[:value])
    end
  end

end
