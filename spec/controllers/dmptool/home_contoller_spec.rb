# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dmptool::HomeController, type: :request do
  include DmptoolHelper

  before(:each) do
    @controller = ::HomeController.new
    mock_blog
  end

  it 'HomeController includes our customizations' do
    expect(@controller.respond_to?(:index)).to eql(true)
  end

  describe '#index' do
    it '#page is accessible when not logged in' do
      get root_path
      # Request specs are expensive so just check everything in this one test
      expect(response).to have_http_status(:success), 'should have received a 200'
      expect(response.body.include?('en-GB')).to eql(true)
      expect(response.body.include?('Funder Requirements</a>')).to eql(true)
      expect(response.body.include?('<h1>Create Data Management Plans that meet')).to eql(true)
      expect(response.body.include?('<h2>Sign in / Sign up')).to eql(true)
      expect(response.body.include?('Participating Institutions')).to eql(true)
      expect(response.body.include?('Latest News from DMPTool')).to eql(true)
      expect(response.body.include?('DMPTool is a service of the')).to eql(true)
    end

    it '#page is NOT accessible when logged in' do
      sign_in(create(:user))
      get root_path
      # Request specs are expensive so just check everything in this one test
      expect(response).to redirect_to(plans_path)
    end
  end
end
