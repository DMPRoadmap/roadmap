require 'rails_helper'

RSpec.describe 'DMPTool custom endpoints to static pages', type: :request do

  it "#promote should be accessible when not logged in" do
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
