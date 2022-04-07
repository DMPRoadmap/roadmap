# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/modal_search/_form.html.erb' do
  before(:each) do
    @model = create(:plan)
  end

  it 'defaults to :search_examples to an empty string and :results to an empty array' do
    render partial: 'layouts/modal_search/form',
           locals: {
             namespace: nil,
             label: nil,
             search_examples: nil,
             model_instance: @model,
             search_path: nil,
             search_method: nil
           }
    expect(rendered.include?('- Enter a search term  -')).to eql(true)
    expect(rendered.include?('No results matched your filter criteria.')).to eql(true)
  end

  it 'uses the specified :search_examples' do
    examples = Faker::Lorem.sentence
    render partial: 'layouts/modal_search/form',
           locals: {
             namespace: nil,
             label: nil,
             search_examples: examples,
             model_instance: @model,
             search_path: nil,
             search_method: nil
           }
    expect(rendered.include?(examples)).to eql(true)
  end

  it 'uses the :namespace when defining the modal search sections' do
    namespace = Faker::Lorem.word.downcase
    render partial: 'layouts/modal_search/form',
           locals: {
             namespace: namespace,
             label: nil,
             search_examples: nil,
             model_instance: @model,
             search_path: nil,
             search_method: nil
           }
    expect(rendered.include?("modal-search-#{namespace}")).to eql(true)
    expect(rendered.include?("modal-search-#{namespace}-filters")).to eql(true)
    expect(rendered.include?("modal-search-#{namespace}-results")).to eql(true)
  end

  it 'Uses the :label for the button' do
    label = Faker::Lorem.word
    render partial: 'layouts/modal_search/form',
           locals: {
             namespace: nil,
             label: label,
             search_examples: nil,
             model_instance: @model,
             search_path: nil,
             search_method: nil
           }
    expect(rendered.include?("#{label} search")).to eql(true)
  end

  it 'Uses the :model_instance when adding the form element' do
    render partial: 'layouts/modal_search/form',
           locals: {
             namespace: nil,
             label: nil,
             search_examples: nil,
             model_instance: @model,
             search_path: nil,
             search_method: nil
           }
    expect(rendered.include?(plan_path(@model))).to eql(true)
  end

  it 'Uses the :search_path when adding the form element' do
    url = Faker::Internet.url
    render partial: 'layouts/modal_search/form',
           locals: {
             namespace: nil,
             label: nil,
             search_examples: nil,
             model_instance: @model,
             search_path: url,
             search_method: nil
           }
    expect(rendered.include?(url)).to eql(true)
  end

  it 'Uses the :search_method when adding the form element' do
    method = %i[get put post patch delete].sample
    render partial: 'layouts/modal_search/form',
           locals: {
             namespace: nil,
             label: nil,
             search_examples: nil,
             model_instance: @model,
             search_path: nil,
             search_method: method
           }
    expect(rendered.include?(method.to_s)).to eql(true)
  end
end
