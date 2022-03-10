# frozen_string_literal: true

require 'rails_helper'

describe 'public_pages/orgs.html.erb' do
  include DmptoolHelper

  it 'renders our version of the page' do
    3.times do
      org = create(:org)
      shibbolize_org(org: org)
    end

    controller.prepend_view_path 'app/views/branded'
    assign :orgs, Org.participating
    render
    expect(rendered.include?('Participating Institutions')).to eql(true)
    expect(response).to render_template(partial: 'paginable/orgs/_public')
  end
end
