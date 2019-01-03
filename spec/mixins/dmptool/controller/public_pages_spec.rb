require 'rails_helper'

RSpec.describe 'DMPTool custom endpoints for public pages', type: :request do

  describe '#orgs' do

    let!(:funder) { create(:org, :funder) }
    let!(:institution) { create(:org, :institution) }
    let!(:organisation) { create(:org, :organisation) }

    it "should be accessible when not logged in" do
      get public_orgs_path
      expect(response).to have_http_status(:success)
    end

    it 'should not include a funder Org' do
      get public_orgs_path
      expect(response.body.include?("<td>#{funder.name}")).to eql(false)
    end

    it 'returns json that includes the logo if the org has a logo' do
      get public_orgs_path
      expect(response.body.include?("<td>#{institution.name}")).to eql(true)
      expect(response.body.include?("<td>#{organisation.name}")).to eql(true)
    end

  end

  describe "#get_started" do

    it "should be accessible when not logged in" do
      get get_started_path
      expect(response).to have_http_status(:success)
    end

  end

  describe "strip newline and punctuation characters from file_name for PDF/DOCX" do
    class TestPublicPagesController < PublicPagesController
      def test_file_name(name)
        file_name(name)
      end
    end

    let!(:ctrl) { TestPublicPagesController.new }

    it "replaces spaces, periods, commas, and colons with underscores" do
      expect(ctrl.test_file_name("A title with spaces")).to eql("A_title_with_spaces")
      expect(ctrl.test_file_name("A title with, comma")).to eql("A_title_with_comma")
      expect(ctrl.test_file_name("A title with. period")).to eql("A_title_with_period")
      expect(ctrl.test_file_name("A title with: colon")).to eql("A_title_with_colon")
      expect(ctrl.test_file_name("A title with; semicolon")).to eql("A_title_with_semicolon")
    end

    it "removes newlines and carriage returns" do
      expect(ctrl.test_file_name("A title with\nnewline")).to eql("A_title_with_newline")
      expect(ctrl.test_file_name("A title with\rcarriage return")).to eql("A_title_with_carriage_return")
      expect(ctrl.test_file_name("A title with\r\nboth")).to eql("A_title_with__both")
      expect(ctrl.test_file_name("A title with
newline")).to eql("A_title_with_newline")
    end

    it "only uses the first 30 characters" do
      expect(ctrl.test_file_name("0123456789012345678901234567890B")).to eql("0123456789012345678901234567890")
    end
  end

end
