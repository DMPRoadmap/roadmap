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

  describe 'GET /org_admin/templates/:id/email - :email_org_admin_template', js: true do
    it '#page is accessible when logged in' do
      sign_in(@admin)
      get email_org_admin_template_path(@template, format: :js)
      # Expect the user to be shown a success message
      expect(response).to redirect_to(organisational_org_admin_templates_path)
      expect(flash[:notice].present?).to eql(true)
      # Ensure that the new plan was created
      expect(Plan.last.template).to eql(@template)
      expect(Plan.last.owner).to eql(@invitee)
    end

    it '#page is NOT accessible when not logged in' do
      get email_org_admin_template_path(@template)
      # Request specs are expensive so just check everything in this one test
      expect(response).to redirect_to(root_path)
      expect(flash[:alert].present?).to eql(true)
    end
    it '#page is NOT accessible when logged in user is not an admin' do
      sign_in(create(:user))
      get email_org_admin_template_path(@template)
      # Request specs are expensive so just check everything in this one test
      expect(response).to redirect_to(plans_path)
      expect(flash[:alert].present?).to eql(true)
    end
  end
end
