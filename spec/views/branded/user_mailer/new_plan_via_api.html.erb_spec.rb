# frozen_string_literal: true

require 'rails_helper'

describe 'user_mailer/new_plan_via_api' do
  before(:each) do
    controller.prepend_view_path 'app/views/branded'
  end

  it 'renders correctly' do
    client = create(:api_client, name: 'foo', description: 'Foo bar')
    plan = create(:plan, :creator, template: create(:template, org: create(:org)))
    user = plan.owner

    assign :user, user
    assign :plan, plan
    assign :api_client, client

    render
    expected = "created for you by the #{CGI.escapeHTML(client.description)}"
    expect(rendered.include?(expected)).to eql(true)
    expect(rendered.include?(plan.template.org&.contact_email)).to eql(true)
    expect(rendered.include?(CGI.escapeHTML(user.name(false)))).to eql(true)
    expect(rendered.include?(CGI.escapeHTML(plan.title))).to eql(true)
    expect(response).to render_template(partial: 'user_mailer/_email_signature')
  end
end
