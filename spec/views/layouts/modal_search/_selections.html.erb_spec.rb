# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/modal_search/_selections.html.erb' do
  before(:each) do
    @namespace = Faker::Lorem.word.downcase
    @label = Faker::Lorem.sentence
    render partial: 'layouts/modal_search/selections',
           locals: {
             namespace: @namespace,
             button_label: @label,
             results: [],
             item_name_attr: Faker::Lorem.word,
             result_partial: nil,
             search_path: nil,
             search_method: nil
           }
  end

  it 'adds the :namespace to the selections block' do
    expect(rendered.include?("modal-search-#{@namespace}-selections")).to eql(true)
  end

  it 'adds the :namespace to the button' do
    expect(rendered.include?("target=\"#modal-search-#{@namespace}\"")).to eql(true)
  end

  it 'sets the :button_label on the button' do
    expect(rendered.include?(@label)).to eql(true)
  end

  it 'adds the renders the results partial' do
    expect(response).to render_template(partial: 'layouts/modal_search/_results')
  end
end
