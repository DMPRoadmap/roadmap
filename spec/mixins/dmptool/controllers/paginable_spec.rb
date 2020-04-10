require 'rails_helper'

RSpec.describe 'DMPTool custom endpoint to public Orgs paginated page', type: :request do

  describe '#public' do

    let!(:funder) { create(:org, :funder) }
    let!(:institution) { create(:org, :institution) }
    let!(:organisation) { create(:org, :organisation) }
    let!(:research_institute) { create(:org, :research_institute) }
    let!(:project) { create(:org, :project) }
    let!(:school) { create(:org, :school) }

    it "should be accessible when not logged in" do
      get public_paginable_orgs_path(1)
      expect(response).to have_http_status(:success)
    end

    it "should not include funder Org" do
      get public_paginable_orgs_path(1)
      expect(response.body.include?(funder.name)).to eql(false)
    end

    it 'should include any non-funder Orgs' do
      get public_paginable_orgs_path(1)
      expect(response.body.include?(institution.name)).to eql(true)
      expect(response.body.include?(organisation.name)).to eql(true)
      expect(response.body.include?(research_institute.name)).to eql(true)
      expect(response.body.include?(project.name)).to eql(true)
      expect(response.body.include?(school.name)).to eql(true)
    end

  end

end
