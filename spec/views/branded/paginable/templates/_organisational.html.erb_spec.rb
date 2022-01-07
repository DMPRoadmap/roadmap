# frozen_string_literal: true

require 'rails_helper'

describe 'paginable/templates/_organisational.html.erb' do

  it 'renders our version of the page' do
    template = create(:template, published: true)
    controller.prepend_view_path 'app/views/branded'
    assign :paginable_path_params, { sort_field: 'templates.title', sort_direction: :asc }
    assign :paginable_options, {}
    assign :args, { controller: 'paginable/templates', action: 'organisational' }
    # Paginable is expecting `scope` to be a local not an instance variable
    render partial: 'paginable/templates/organisational', locals: { scope: Template.all }

    expect(rendered.include?('class="c-template-title"')).to eql(true)
    expect(rendered.include?('class="c-template-invitation"')).to eql(true)
    expect(rendered.include?('Email template')).to eql(true)

    expect(response).to render_template(partial: 'paginable/templates/_invite_modal')
  end
end
