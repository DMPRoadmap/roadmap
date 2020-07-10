# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/usage_downloads", type: :request do
  describe "#index" do
    it "redirects when non-authorized user" do
      get "/usage_downloads"

      expect(response).to have_http_status(:redirect)
    end

    context "when authorized user" do
      let(:org_admin) { create(:user, :org_admin) }
      let(:super_admin) { create(:user, :super_admin) }

      it "org_admin gets csv file" do
        sign_in(org_admin)

        get "/usage_downloads"

        expect(response.content_type).to eq("text/csv")
        expect(response).to have_http_status(:ok)
      end

      it "super_admin gets csv file" do
        sign_in(super_admin)

        get "/usage_downloads"

        expect(response.content_type).to eq("text/csv")
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
