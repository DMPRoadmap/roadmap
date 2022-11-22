# frozen_string_literal: true

require 'rails_helper'

describe 'user_mailer/new_plan_via_template' do
  before do
    controller.prepend_view_path 'app/views/branded'
  end

  it 'renders correctly' do
    sender = create(:user, org: create(:org))
    plan = create(:plan, :creator, template: create(:template, org: create(:org)))
    user = plan.owner

    assign :user, user
    assign :plan, plan
    assign :sender, sender
    assign :message, 'Foo %{dmp_title} bar %{org_name} baz %{org_admin_email}'

    render
    expect(rendered.include?('Please sign in to the')).to be(true)
    expected = "Foo #{CGI.escapeHTML(plan.title)} bar #{CGI.escapeHTML(sender.org.name)}"
    expected += " baz #{sender.org.contact_email}"
    expect(rendered.include?(expected)).to be(true)
    expect(rendered.include?(user.name(false))).to be(true)
    expect(rendered.include?(plan.title)).to be(true)
    expect(rendered.include?("The #{CGI.escapeHTML(sender.org.name)} DMPTool team")).to be(true)
    expect(rendered.include?('Please do not reply to this email.')).to be(true)
  end
end
