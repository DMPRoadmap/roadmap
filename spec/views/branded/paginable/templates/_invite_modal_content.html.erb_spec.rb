# frozen_string_literal: true

require 'rails_helper'

describe 'paginable/templates/_invite_modal_content.html.erb' do
  it 'renders the modal dialog content' do
    controller.prepend_view_path 'app/views/branded'
    template = create(:template)
    render partial: '/paginable/templates/invite_modal_content', locals: { template: template }
    expect(rendered.include?('class="c-modal-invite-instructions"')).to be(true)
    expect(rendered.include?('id="plan_user_email"')).to be(true)
    expect(rendered.include?('You can use the default email subject and body below')).to be(true)
    expect(rendered.include?('id="plan_template_attributes_id"')).to be(true)
    expect(rendered.include?('id="plan_template_attributes_email_subject"')).to be(true)
    expect(rendered.include?('id="plan_template_attributes_email_body"')).to be(true)
    expect(rendered.include?('template-email-preview-panel')).to be(true)
    expect(rendered.include?('class="replaceable-template-email-welcome"')).to be(true)
    expect(rendered.include?('class="replaceable-template-email-content"')).to be(true)
    expect(rendered.include?('Send email')).to be(true)
  end
end
