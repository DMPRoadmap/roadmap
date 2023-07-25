# frozen_string_literal: true

require 'rails_helper'

describe 'user_mailer/invitation' do
  include Helpers::DmptoolHelper

  before do
    controller.prepend_view_path 'app/views/branded'

    @plan = create(:plan, org: create(:org), template: create(:template, org: create(:org)))
    assign :plan, @plan
    assign :org_name, @plan.template.org.name
    assign :org_email, @plan.template.org.contact_email

    @invitee = create(:user)
    assign :invitee, @invitee
  end

  it 'renders correctly when the inviter is a ApiClient (via API V2 plan creation)' do
    @plan.template.org.api_create_plan_email_body = 'Foo %{external_system_name} bar'

    inviter = create(:api_client)
    assign :inviter_type, 'ApiClient'
    assign :inviter_name, inviter.name
    assign :client_name, inviter.description

    render
    expect(rendered.include?("Hello #{CGI.escapeHTML(@invitee.name)}")).to be(true)
    expect(rendered.include?("Foo #{inviter.description} bar")).to be(true)
    expect(rendered.include?('Please sign in or sign up at <a')).to be(true)
    expected = "The #{CGI.escapeHTML(@plan.template.org.name)} DMPTool team"
    expect(rendered.include?(expected)).to be(true)
    expect(rendered.include?(@plan.template.org.contact_email)).to be(true)
  end

  it 'renders correctly when the inviter is a Org (via Email Template modal)' do
    @plan.template.email_body = 'Foo %{dmp_title} bar %{org_name} baz %{org_admin_email}'

    inviter = create(:org)
    assign :inviter_type, 'Org'
    assign :inviter_name, inviter.name

    render
    expect(rendered.include?("Hello #{CGI.escapeHTML(@invitee.name)}")).to be(true)
    expected = "Foo #{CGI.escapeHTML(@plan.title)} bar #{CGI.escapeHTML(@plan.template.org.name)} baz"
    expect(rendered.include?(expected)).to be(true)
    expect(rendered.include?(CGI.escapeHTML(@plan.template.org.name))).to be(true)
    expect(rendered.include?('Please sign in or sign up at <a')).to be(true)
    expected = "The #{CGI.escapeHTML(@plan.template.org.name)} DMPTool team"
    expect(rendered.include?(expected)).to be(true)
    expect(rendered.include?(@plan.template.org.contact_email)).to be(true)
  end

  it 'renders correctly when the inviter is a User (via Contributors tab)' do
    inviter = create(:user)
    assign :inviter_type, 'User'
    assign :inviter_name, inviter.name(false)

    render
    expect(rendered.include?("Hello #{CGI.escapeHTML(@invitee.name(false))}")).to be(true)
    expected = "Your colleague #{CGI.escapeHTML(inviter.name(false))} has invited you"
    expect(rendered.include?(expected)).to be(true)
    expect(rendered.include?(inviter.name(false)))
    expect(rendered.include?('Please sign in or sign up at <a')).to be(true)
    expect(response).to render_template(partial: 'user_mailer/_email_signature')
  end

  it 'uses the invitee email instead of stub name if the user has an active invitation' do
    @invitee.invitation_token = SecureRandom.uuid
    @invitee.invitation_accepted_at = nil

    inviter = create(:user)
    assign :inviter_type, 'User'
    assign :inviter_name, inviter.name(false)

    render
    expect(rendered.include?("Hello #{@invitee.email}")).to be(true)
  end
end
