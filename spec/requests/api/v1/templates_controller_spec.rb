# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::TemplatesController, type: :request do

  include ApiHelper

  context "ApiClient" do

    before(:each) do
      mock_authorization_for_api_client
    end

    describe "GET /api/v1/templates - index" do
      it "returns a even if there are no public templates" do
        get api_v1_templates_path
        expect(response.code).to eql("200")
        expect(response).to render_template("api/v1/templates/index")
        expect(assigns(:items).empty?).to eql(true)
      end

      it "returns a public published template" do
        create(:template, :publicly_visible, published: true, customization_of: nil)
        get api_v1_templates_path
        expect(assigns(:items).length).to eql(1)
      end

      it "does not return an unpublished template" do
        create(:template, :publicly_visible, published: false, customization_of: nil)
        get api_v1_templates_path
        expect(assigns(:items).length).to eql(0)
      end

      it "does not return an organizational template" do
        get api_v1_templates_path
        create(:template, :organisationally_visible, :published, customization_of: nil)
        get api_v1_templates_path
        expect(assigns(:items).length).to eql(0)
      end
    end

  end

  context "User" do

    before(:each) do
      mock_authorization_for_user
    end

    describe "GET /api/v1/templates - index" do
      it "returns a even if there are no public templates" do
        get api_v1_templates_path
        expect(response.code).to eql("200")
        expect(response).to render_template("api/v1/templates/index")
        expect(assigns(:items).empty?).to eql(true)
      end

      it "returns a public published template" do
        create(:template, :publicly_visible, :published, customization_of: nil)
        get api_v1_templates_path
        expect(assigns(:items).length).to eql(1)
      end

      it "returns a organizational published template (for user's org)" do
        create(:template, :organisationally_visible, :published, org: Org.last,
                                                                 customization_of: nil)
        get api_v1_templates_path
        expect(assigns(:items).length).to eql(1)
      end

      it "does not return an unpublished template" do
        create(:template, :organisationally_visible, published: false,
                                                     org: Org.last, customization_of: nil)
        get api_v1_templates_path
        expect(assigns(:items).length).to eql(0)
      end

      it "does not return another Org's organizational template" do
        org2 = create(:org)
        get api_v1_templates_path
        create(:template, :organisationally_visible, published: true, org: org2,
                                                     customization_of: nil)
        get api_v1_templates_path
        expect(assigns(:items).length).to eql(0)
      end
    end

  end

end
