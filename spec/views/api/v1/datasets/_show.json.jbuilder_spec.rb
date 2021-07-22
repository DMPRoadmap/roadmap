# frozen_string_literal: true

require "rails_helper"

describe "api/v1/datasets/_show.json.jbuilder" do

  before(:each) do
    # TODO: Implement this once the Dataset models are in place
    @plan = create(:plan)
    render partial: "api/v1/datasets/show", locals: { plan: @plan }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe "includes all of the dataset attributes" do
    it "includes :title" do
      expect(@json[:title]).to eql("Generic Dataset")
    end
    it "includes :personal_data" do
      expect(@json[:personal_data]).to eql("unknown")
    end
    it "includes :sensitive_data" do
      expect(@json[:sensitive_data]).to eql("unknown")
    end
    it "includes :dataset_id" do
      expect(@json[:dataset_id][:type]).to eql("url")
      url = Rails.application.routes.url_helpers.api_v1_plan_url(@plan)
      expect(@json[:dataset_id][:identifier]).to eql(url)
    end
  end

end
