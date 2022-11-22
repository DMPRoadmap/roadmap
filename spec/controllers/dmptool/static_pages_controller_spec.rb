# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dmptool::StaticPagesController, type: :request do
  before do
    @controller = ::StaticPagesController.new
  end

  it 'StaticPagesController includes our customizations' do
    expect(@controller.respond_to?(:faq)).to be(true)
  end

  it '#pages are accessible when not logged in' do
    get promote_path
    expect(response).to have_http_status(:success)
    expect(response.body.include?('<h1>Promote the DMPTool')).to be(true)
  end

  it '#faq should be accessible when not logged in' do
    get faq_path
    expect(response).to have_http_status(:success)
    expect(response.body.include?('<h1>FAQ')).to be(true)
  end

  it '#general_guidance should be accessible when not logged in' do
    get general_guidance_path
    expect(response).to have_http_status(:success)
    expect(response.body.include?('<h1>Data management general guidance')).to be(true)
  end
end
