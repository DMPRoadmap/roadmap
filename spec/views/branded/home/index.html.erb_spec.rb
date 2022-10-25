# frozen_string_literal: true

require 'rails_helper'

describe 'home/index' do
  include Helpers::DmptoolHelper

  it 'renders our version of the page' do
    mock_blog
    controller.prepend_view_path 'app/views/branded'

    stats = {
      user_count: Faker::Number.number,
      completed_plan_count: Faker::Number.number,
      institution_count: Faker::Number.number
    }
    assign :stats, stats
    assign :top_five, [build(:template).title]

    # Need to specify a layout here since the template uses a :content_for block
    render template: 'home/index', layout: 'layouts/application'

    expect(rendered.include?('class="c-calltoaction')).to be(true)
    expect(rendered.include?('class="c-login')).to be(true)
    expect(rendered.include?('class="c-home-stats__users"')).to be(true)
    expect(rendered.include?('class="c-home-stats__participants"')).to be(true)
    expect(rendered.include?('class="c-home-stats__plans"')).to be(true)
    expect(rendered.include?('class="c-blog"')).to be(true)
    expect(rendered.include?('class="c-blog__content"')).to be(true)
    expect(rendered.include?('class="c-social"')).to be(true)
    expect(rendered.include?('class="c-social__icon-twitter"')).to be(true)
    expect(rendered.include?('class="c-social__icon-rss"')).to be(true)
    expect(response).to render_template(partial: 'users/sessions/_validate')
  end
end
