# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dmptool::OrgAdmin::PlansController, type: :request do
  include DmptoolHelper

  before(:each) do
    @admin = create(:user, :org_admin, org: create(:org))
    @invitee = create(:user, org: @admin.org)
    @template = create(:template, :publicly_visible, :published, org: @admin.org, phases: 1,
                                                                 sections: 1, questions: 2)
    @args = {
      user: { email: @invitee.email },
      template_attributes: {
        id: @template.id,
        email_subject: @template.email_subject,
        email_body: @template.email_body
      }
    }

    @controller = ::OrgAdmin::PlansController.new
  end

  it 'OrgAdmin::PlansController includes our customizations' do
    expect(@controller.respond_to?(:create)).to eql(true)
  end

  describe 'POST /org_admin/plans - :create' do
    it '#page is accessible when logged in' do
      sign_in(@admin)
      post org_admin_plans_path, params: { plan: @args }
      # Expect the user to be shown a success message
      expect(response).to redirect_to(organisational_org_admin_templates_path)
      expect(flash[:notice].present?).to eql(true)
      # Ensure that the new plan was created
      expect(Plan.last.template).to eql(@template)
      expect(Plan.last.owner).to eql(@invitee)
    end

    it '#page is NOT accessible when not logged in' do
      post org_admin_plans_path, params: { plan: @args }
      # Request specs are expensive so just check everything in this one test
      expect(response).to redirect_to(root_path)
      expect(flash[:alert].present?).to eql(true)
    end
    it '#page is NOT accessible when logged in user is not an admin' do
      sign_in(create(:user))
      post org_admin_plans_path, params: { plan: @args }
      # Request specs are expensive so just check everything in this one test
      expect(response).to redirect_to(plans_path)
      expect(flash[:alert].present?).to eql(true)
    end
  end

  context 'private methods' do
    before(:each) do
      @plan = build(:plan)

      # Since these are fired outside the context of the request-response cycle we need
      # to stub the current_user method
      @controller.stubs(:current_user).returns(@admin)
      @controller.stubs(:plan_params).returns({ user: { email: @invitee.email } })
    end

    describe ':notify_user(user:, plan:)' do
      it 'returns false if :user is not present' do
        expect(@controller.send(:notify_user, user: nil, plan: @plan)).to eql(false)
      end
      it 'returns false if :plan is not present' do
        expect(@controller.send(:notify_user, user: @invitee, plan: nil)).to eql(false)
      end
      it 'invites the :user if they are a new record' do
        user = build(:user)
        @controller.send(:notify_user, user: user, plan: @plan)

        email = ActionMailer::Base.deliveries.first
        expect(email.is_a?(Mail::Message)).to eql(true)
        expect(email.to).to eql([user.email])
        expect(email.subject).to eql(@plan.template.email_subject)
        expect(email.body.to_s.include?(user.email)).to eql(true)
        expect(email.body.to_s.include?(@plan.template.email_body)).to eql(true)
      end
      it 'emails the existing :user' do
        @controller.send(:notify_user, user: @invitee, plan: @plan)

        email = ActionMailer::Base.deliveries.first
        expect(email.is_a?(Mail::Message)).to eql(true)
        expect(email.to).to eql([@invitee.email])
        expect(email.subject).to eql(@plan.template.email_subject)
        expect(email.body.to_s.include?(@invitee.name(false))).to eql(true)
        expect(email.body.to_s.include?(@plan.template.email_body)).to eql(true)
      end
    end
  end
end
