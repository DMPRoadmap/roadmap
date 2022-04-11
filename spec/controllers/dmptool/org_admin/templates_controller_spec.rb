# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dmptool::OrgAdmin::TemplatesController, type: :request do
  include DmptoolHelper

  before(:each) do
    @admin = create(:user, :org_admin, org: create(:org))
    @template = create(:template, :publicly_visible, :published, org: @admin.org, phases: 1,
                                                                 sections: 1, questions: 2)
    @controller = ::OrgAdmin::TemplatesController.new
  end

  it 'OrgAdmin::TemplatesController includes our customizations' do
    expect(@controller.respond_to?(:email)).to eql(true)
  end

  describe 'GET /org_admin/templates/:id/email - :email_org_admin_template' do
    it 'page is accessible when logged in and uses template\'s existing email values' do
      sign_in(@admin)
      get email_org_admin_template_path(@template), xhr: true
      # Expect the user to be shown a success message
      expect(response.code).to eql('200')
      template = assigns(:template)
      expect(template.present?).to eql(true)
      expect(template.email_subject).to eql(@template.email_subject)
      expect(template.email_body).to eql(@template.email_body)
    end
    it 'uses default email values' do
      sign_in(@admin)
      @template.update(email_subject: nil, email_body: nil)
      get email_org_admin_template_path(@template), xhr: true
      # Expect the user to be shown a success message
      expect(response.code).to eql('200')
      template = assigns(:template)
      expect(template.present?).to eql(true)
      subject = format(_('A new data management plan (DMP) for the %{org_name} was started for you.'),
                       org_name: @template.org.name)
      # rubocop:disable Layout/LineLength
      body = format(
        _('An administrator from the %{org_name} has started a new data management plan (DMP) for you. If you have any questions or need help, please contact them at %{org_admin_email}.'), org_name: @template.org.name, org_admin_email: "<a href=\"#{@template.org.contact_email}\">#{@template.org.contact_email}</a>"
      )
      # rubocop:enable Layout/LineLength
      expect(template.email_subject).to eql(subject)
      expect(template.email_body).to eql(body)
    end
    it 'page is NOT accessible when not logged in' do
      get email_org_admin_template_path(@template), xhr: true
      # Request specs are expensive so just check everything in this one test
      expect(response).to redirect_to(root_path)
      expect(flash[:alert].present?).to eql(true)
    end
    it 'page is NOT accessible when logged in user is not an admin' do
      sign_in(create(:user))
      get email_org_admin_template_path(@template), xhr: true
      # Request specs are expensive so just check everything in this one test
      expect(response).to redirect_to(plans_path)
      expect(flash[:alert].present?).to eql(true)
    end
  end
end
