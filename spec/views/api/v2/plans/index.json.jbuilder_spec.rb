# frozen_string_literal: true

require 'rails_helper'

describe 'api/v2/plans/index.json.jbuilder' do
  before do
    @plan = create(:plan)

    @client = create(:api_client)
    @items = [@plan]
    @total_items = 1

    render template: 'api/v2/plans/index'
    @json = JSON.parse(rendered).with_indifferent_access
  end

  it 'renders the _standard_response template' do
    expect(response).to render_template('api/v2/_standard_response')
  end

  it ':items array to be empty' do
    expect(@json[:items].length).to be(1)
    expect(@json[:items].first[:dmp][:title]).to eql(@plan.title)
  end
end
