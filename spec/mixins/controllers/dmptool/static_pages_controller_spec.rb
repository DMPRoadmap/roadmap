# frozen_string_literal: true

require "rails_helper"

RSpec.describe Controllers::Dmptool::StaticPagesController, type: :request do

  before(:each) do
    @controller = ::StaticPagesController.new
  end

  it "StaticPagesController includes our customizations" do
    expect(@controller.respond_to?(:faq)).to eql(true)
  end

  it "#pages are accessible when not logged in" do
    get promote_path
    expect(response).to have_http_status(:success)
    expect(response.body.include?("<h1>Promote the DMPTool")).to eql(true)
  end

  it "#faq should be accessible when not logged in" do
    get faq_path
    expect(response).to have_http_status(:success)
    expect(response.body.include?("<h1>FAQ")).to eql(true)
  end

  it "#general_guidance should be accessible when not logged in" do
    get general_guidance_path
    expect(response).to have_http_status(:success)
    expect(response.body.include?("<h1>Data management general guidance")).to eql(true)
  end

end
