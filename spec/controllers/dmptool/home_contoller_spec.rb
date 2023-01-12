# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dmptool::HomeController, type: :request do
  include Helpers::DmptoolHelper

  before do
    @controller = HomeController.new
    mock_blog
  end

  it 'HomeController includes our customizations' do
    expect(@controller.respond_to?(:index)).to be(true)
  end

  describe '#index' do
    it '#page is accessible when not logged in' do
      get root_path
      # Request specs are expensive so just check everything in this one test
      expect(response).to have_http_status(:success), 'should have received a 200'
      expect(response.body.include?('Language')).to be(true)
      expect(response.body.include?('Funder Requirements</a>')).to be(true)
      expect(response.body.include?('<h1>Create Data Management Plans that meet')).to be(true)
      expect(response.body.include?('<h2>Sign in / Sign up')).to be(true)
      expect(response.body.include?('Participating Institutions')).to be(true)
      expect(response.body.include?('Latest News from DMPTool')).to be(true)
      expect(response.body.include?('DMPTool is a service of the')).to be(true)
    end

    it '#page is NOT accessible when logged in' do
      sign_in(create(:user))
      get root_path
      # Request specs are expensive so just check everything in this one test
      expect(response).to redirect_to(plans_path)
    end
  end
end
