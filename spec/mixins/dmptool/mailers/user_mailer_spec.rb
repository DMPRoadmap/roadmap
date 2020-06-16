# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dmptool::Mailers::UserMailer, type: :mailer do

  describe "DMPTool mixin for the UserMailer" do

    before do
      @plan = build(:plan)
      @contributor = build(:contributor, plan: @plan)
    end

    # TODO: Enable these tests once the contributor code is in place

    xit "UserMailer includes our cusotmizations" do
      expect(UserMailer.respond_to?(:api_plan_creation)).to eql(true)
    end

    context "#api_plan_creation(plan, contributor)" do

      xit "does not send an email if :plan is not present" do
        UserMailer.api_plan_creation(nil, @contributor)
        expect(ActionMailer::Base.deliveries.size).to eql(0)
      end
      xit "does not send an email if :contributor is not present" do
        UserMailer.api_plan_creation(@plan, nil)
        expect(ActionMailer::Base.deliveries.size).to eql(0)
      end

      context "success" do
        before(:each) do
          @mail = UserMailer.api_plan_creation(@plan, @contributor)
        end

        xit "Has the correct :subject" do
          expect(@mail.subject).to eql(_("New DMP created"))
        end
        xit "Has the correct :to recipients" do
          expect(@mail.to.include?("brian.riley@ucop.edu")).to eql(true)
        end
        xit "renders the correct template" do
          expected = "a new DMP was created via the API"
          expect(@mail.body.encoded.include?(expected)).to eql(true)
        end
      end

    end

  end

end
