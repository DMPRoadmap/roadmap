# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/modal_search/_selections.html.erb' do
  before(:each) do
    create(:repository)
    @msg = 'No results matched your filter criteria.'
  end

  it 'defaults :results to an empty array, :selected to false, and has a default :no_results_msg' do
    render partial: 'layouts/modal_search/results',
           locals: {
             namespace: nil,
             item_name_attr: nil,
             result_partial: nil,
             search_path: nil,
             search_method: nil
           }
    expect(rendered.include?(@msg)).to eql(true)
  end

  context 'when :selected is false' do
    it 'displays pagination when :results is not empty and does not display no results message' do
      render partial: 'layouts/modal_search/results',
             locals: {
               namespace: nil,
               results: Repository.all.page(1),
               selected: false,
               item_name_attr: nil,
               result_partial: nil,
               search_path: nil,
               search_method: nil
             }
      expect(rendered.include?('modal-search-results-pagination')).to eql(true)
      expect(rendered.include?(@msg)).to eql(false)
    end
    it 'does not display pagination when :results is empty and displays the message' do
      render partial: 'layouts/modal_search/results',
             locals: {
               namespace: nil,
               results: [],
               selected: false,
               item_name_attr: nil,
               result_partial: nil,
               search_path: nil,
               search_method: nil
             }
      expect(rendered.include?('modal-search-results-pagination')).to eql(false)
      expect(rendered.include?(@msg)).to eql(true)
    end
  end

  context 'when :selected is true' do
    it 'does not display pagination when :results is not empty and does not display message' do
      render partial: 'layouts/modal_search/results',
             locals: {
               namespace: nil,
               results: Repository.all.page(1),
               selected: true,
               item_name_attr: nil,
               result_partial: nil,
               search_path: nil,
               search_method: nil
             }
      expect(rendered.include?('modal-search-results-pagination')).to eql(false)
      expect(rendered.include?(@msg)).to eql(false)
    end
    it 'does not display pagination when :results is empty and does not display message' do
      render partial: 'layouts/modal_search/results',
             locals: {
               namespace: nil,
               results: [],
               selected: true,
               item_name_attr: nil,
               result_partial: nil,
               search_path: nil,
               search_method: nil
             }
      expect(rendered.include?('modal-search-results-pagination')).to eql(false)
      expect(rendered.include?(@msg)).to eql(false)
    end
  end
end
