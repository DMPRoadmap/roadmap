# frozen_string_literal: true

require 'rails_helper'

describe 'api/v2/heartbeat.json.jbuilder' do
  before(:each) do
    render template: 'api/v2/heartbeat', locals: { response: @resp, request: @req }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  it 'renders the _standard_response template' do
    expect(response).to render_template('api/v2/_standard_response')
  end
  it ':items array to be empty' do
    expect(@json[:items]).to eql([])
  end
end
