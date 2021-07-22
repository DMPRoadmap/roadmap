# frozen_string_literal: true

require "rails_helper"

describe "api/v1/plans/_show.json.jbuilder" do

  before(:each) do
    @plan = create(:plan)
    @data_contact = create(:contributor, data_curation: true, plan: @plan)
    @pi = create(:contributor, investigation: true, plan: @plan)
    @plan.contributors = [@data_contact, @pi]
    create(:identifier, identifiable: @plan)
    @plan.reload
  end

  describe "includes all of the DMP attributes" do

    before(:each) do
      render partial: "api/v1/plans/show", locals: { plan: @plan }
      @json = JSON.parse(rendered).with_indifferent_access
    end

    it "includes the :title" do
      expect(@json[:title]).to eql(@plan.title)
    end
    it "includes the :description" do
      expect(@json[:description]).to eql(@plan.description)
    end
    it "includes the :language" do
      expected = Api::V1::LanguagePresenter.three_char_code(
        lang: LocaleService.default_locale
      )
      expect(@json[:language]).to eql(expected)
    end
    it "includes the :created" do
      expect(@json[:created]).to eql(@plan.created_at.to_formatted_s(:iso8601))
    end
    it "includes the :modified" do
      expect(@json[:modified]).to eql(@plan.updated_at.to_formatted_s(:iso8601))
    end

    it "returns the URL of the plan as the :dmp_id if no DOI is defined" do
      expected = Rails.application.routes.url_helpers.api_v1_plan_url(@plan)
      expect(@json[:dmp_id][:type]).to eql("url")
      expect(@json[:dmp_id][:identifier]).to eql(expected)
    end

    it "includes the :contact" do
      expect(@json[:contact][:mbox]).to eql(@data_contact.email)
    end
    it "includes the :contributors" do
      emails = @json[:contributor].collect { |c| c[:mbox] }
      expect(emails.include?(@pi.email)).to eql(true)
    end

    # TODO: make sure this is working once the new Cost theme and Currency
    #       question type have been implemented
    it "includes the :cost" do
      expect(@json[:cost]).to eql(nil)
    end

    it "includes the :project" do
      expect(@json[:project].length).to eql(1)
    end
    it "includes the :dataset" do
      expect(@json[:dataset].length).to eql(1)
    end
    it "includes the :extension" do
      expect(@json[:extension].length).to eql(1)
    end
    it "includes the :template in :extension" do
      app = ApplicationService.application_name.split("-").first
      @section = @json[:extension].select { |hash| hash.keys.first == app }.first
      expect(@section[app.to_sym].present?).to eql(true)
      tmplt = @plan.template
      expect(@section[app.to_sym][:template][:id]).to eql(tmplt.id)
      expect(@section[app.to_sym][:template][:title]).to eql(tmplt.title)
    end

  end

  describe "when the system mints DOIs" do
    before(:each) do
      @doi = create(:identifier, value: "10.9999/123abc.zy/x23", identifiable: @plan)
      @plan.reload
      render partial: "api/v1/plans/show", locals: { plan: @plan }
      @json = JSON.parse(rendered).with_indifferent_access
    end

    it "returns the DOI for the :dmp_id if one is present" do
      expect(@json[:dmp_id][:type]).to eql("doi")
      expect(@json[:dmp_id][:identifier]).to eql(@doi.value)
    end
  end

end
