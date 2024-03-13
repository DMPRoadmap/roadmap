# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/modal_search/_result.html.erb' do
  before(:each) do
    @result = build(:repository)
  end

  it 'renders the :result_partial if specified' do
    render partial: 'layouts/modal_search/result',
           locals: {
             item_name_attr: :name,
             result: @result,
             selected: nil,
             result_partial: 'layouts/footer',
             search_path: nil,
             search_method: nil
           }
    expect(response).to render_template(partial: 'layouts/_footer')
  end

  it 'does not render the :result_partial if none is specified' do
    render partial: 'layouts/modal_search/result',
           locals: {
             item_name_attr: :name,
             result: @result,
             selected: nil,
             result_partial: nil,
             search_path: nil,
             search_method: nil
           }
    expect(response).not_to render_template(partial: 'layouts/footer')
  end

  it "displays the result's :item_name_attr" do
    render partial: 'layouts/modal_search/result',
           locals: {
             item_name_attr: :name,
             result: @result,
             selected: true,
             result_partial: nil,
             search_path: nil,
             search_method: nil
           }
    expect(rendered.include?('modal-search-result-selector d-none')).to eql(true)
    expect(rendered.include?('modal-search-result-unselector d-none')).to eql(false)
  end

  it "hides the 'Select' button and shows the 'Remove' button when :selected is true" do
    render partial: 'layouts/modal_search/result',
           locals: {
             item_name_attr: :name,
             result: @result,
             selected: true,
             result_partial: nil,
             search_path: nil,
             search_method: nil
           }
    expect(rendered.include?('modal-search-result-selector d-none')).to eql(true)
    expect(rendered.include?('modal-search-result-unselector d-none')).to eql(false)
  end

  it "shows the 'Select' button and hides the 'Remove' button when :selected is false" do
    render partial: 'layouts/modal_search/result',
           locals: {
             item_name_attr: :name,
             result: @result,
             selected: false,
             result_partial: nil,
             search_path: nil,
             search_method: nil
           }
    expect(rendered.include?('modal-search-result-selector d-none')).to eql(false)
    expect(rendered.include?('modal-search-result-unselector d-none')).to eql(true)
  end
end
