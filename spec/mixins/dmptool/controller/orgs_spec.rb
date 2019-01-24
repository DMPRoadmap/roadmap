require 'rails_helper'

RSpec.describe 'DMPTool custom endpoint to retrieve Org logo/name', type: :request do

  describe '#logos' do

    let!(:org) { create(:org) }

    it "should be accessible when not logged in" do
      get org_logo_path(org.id)
      expect(response).to have_http_status(:success)
    end

    it "should throw a RecordNotFound exception" do
      expect{ get org_logo_path(99999) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns json that includes the org name if the org exists but has no logo' do
      get org_logo_path(org.id)
      json = JSON.parse(response.body)
      expect(assigns(:user).org).to eql(org)
      expect(json["org"]["html"].include?("branding-name")).to eql(true)
    end

    it 'returns json that includes the logo if the org has a logo' do
      org.update_attributes(logo: File.read(Rails.root.join("app", "assets", "images", "logo.png")))
      get org_logo_path(org.id)
      json = JSON.parse(response.body)
      expect(assigns(:user).org).to eql(org)
      expect(json["org"]["html"].include?("org-logo")).to eql(true)
    end

  end

end
