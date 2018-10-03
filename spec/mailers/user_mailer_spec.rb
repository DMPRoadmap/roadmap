require "rails_helper"

RSpec.describe UserMailer, type: :mailer do

  let(:user) { create(:user) }

  describe "#welcome_notification" do

    before do
      Branding.expects(:fetch)
              .with(:application, :name)
              .returns("DMP Test")
      Branding.expects(:fetch)
              .with(:organisation, :helpdesk_email)
              .returns("noreply@dmptest.com")
      Branding.expects(:fetch)
              .with(:organisation, :contact_us_url)
              .returns("http://example.com")

    end

    let(:mail) { UserMailer.welcome_notification(user) }

    it "sets the correct subject" do
      expect(mail.subject).to eq("Welcome to DMP Test")
    end

    it "sets the correct recipient address" do
       expect(mail.to).to eq([user.email])
    end

    it "sets the correct from address" do
      expect(mail.from).to eq(["tester@cc_curation_centre.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Welcome to")
    end

  end

  describe "#sharing_notification" do

    before do
      Branding.expects(:fetch)
              .with(:application, :name)
              .returns("DMP Test")
      Branding.expects(:fetch)
              .with(:organisation, :helpdesk_email)
              .returns("noreply@dmptest.com")
      Branding.expects(:fetch)
              .with(:organisation, :contact_us_url)
              .returns("http://example.com")

    end

    let(:role) { create(:role, :commenter, user: user) }

    let(:inviter) { create(:user) }

    let(:mail) { UserMailer.sharing_notification(role, user, inviter: inviter) }

    it "sets the correct subject" do
      expect(mail.subject).to eq("A Data Management Plan in DMP Test has been shared with you")
    end

    it "sets the correct recipient address" do
       expect(mail.to).to eq([user.email])
    end

    it "sets the correct from address" do
      expect(mail.from).to eq(["tester@cc_curation_centre.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("has invited you to contribute to ")
    end

    it "contains a link to the plan" do
      expect(mail.body.encoded).to have_text(plan_url(role.plan))
    end

  end

  describe "#permissions_change_notification" do

    before do
      Branding.expects(:fetch)
              .with(:application, :name)
              .returns("DMP Test")
      Branding.expects(:fetch)
              .with(:organisation, :helpdesk_email)
              .returns("noreply@dmptest.com")
      Branding.expects(:fetch)
              .with(:organisation, :contact_us_url)
              .returns("http://example.com")

    end

    let(:plan) { create(:plan) }

    let(:role) { create(:role, :commenter, user: user, plan: plan) }

    let(:mail) { UserMailer.permissions_change_notification(role, user) }

    it "sets the correct subject" do
      expect(mail.subject).to eq("Changed permissions on a Data Management Plan in DMP Test")
    end

    it "sets the correct recipient address" do
       expect(mail.to).to eq([user.email])
    end

    it "sets the correct from address" do
      expect(mail.from).to eq(["tester@cc_curation_centre.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Your permissions relating to #{plan.title} have changed. ")
    end

  end

  describe "#plan_access_removed" do

    before do
      Branding.expects(:fetch)
              .with(:application, :name)
              .returns("DMP Test")
      Branding.expects(:fetch)
              .with(:organisation, :helpdesk_email)
              .returns("noreply@dmptest.com")
      Branding.expects(:fetch)
              .with(:organisation, :contact_us_url)
              .returns("http://example.com")

    end

    let(:plan) { create(:plan) }

    let(:remover) { create(:user) }

    let(:mail) { UserMailer.plan_access_removed(user, plan, remover) }

    it "sets the correct subject" do
      expect(mail.subject).to eq("Permissions removed on a DMP in DMP Test")
    end

    it "sets the correct recipient address" do
       expect(mail.to).to eq([user.email])
    end

    it "sets the correct from address" do
      expect(mail.from).to eq(["tester@cc_curation_centre.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_text("Your access to \"#{plan.title}\" has been removed by")
    end

  end

  describe "#feedback_notification" do

    before do
      Branding.expects(:fetch)
              .with(:application, :name)
              .returns("DMP Test")
      Branding.expects(:fetch)
              .with(:organisation, :helpdesk_email)
              .returns("noreply@dmptest.com")
      Branding.expects(:fetch)
              .with(:organisation, :contact_us_url)
              .returns("http://example.com")

    end

    let(:plan) { create(:plan) }

    let(:requestor) { create(:user, firstname: "Tom", surname: "Jones") }

    let(:mail) { UserMailer.feedback_notification(user, plan, requestor) }

    it "sets the correct subject" do
      expect(mail.subject).to eq("DMP Test: #{requestor.name(false)} requested feedback on a plan")
    end

    it "sets the correct recipient address" do
       expect(mail.to).to eq([user.email])
    end

    it "sets the correct from address" do
      expect(mail.from).to eq(["tester@cc_curation_centre.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_text("Tom Jones has requested feedback on a plan")
    end

    it "includes a link to the plan" do
      expect(mail.body.encoded).to have_text(plan_url(plan))
    end

  end

  describe "#feedback_complete" do

    before do
      Branding.expects(:fetch)
              .with(:application, :name)
              .returns("DMP Test")
      Branding.expects(:fetch)
              .with(:organisation, :helpdesk_email)
              .returns("noreply@dmptest.com")
      Branding.expects(:fetch)
              .with(:organisation, :contact_us_url)
              .returns("http://example.com")
    end

    let(:template) { create(:template, phases: 1) }

    let(:plan) { create(:plan, template: template) }

    let(:requestor) { create(:user, firstname: "Tom", surname: "Jones") }

    let(:mail) { UserMailer.feedback_complete(user, plan, requestor) }

    it "sets the correct subject" do
      expect(mail.subject).to eq("DMP Test: Expert feedback has been provided for #{plan.title}")
    end

    it "sets the correct recipient address" do
       expect(mail.to).to eq([user.email])
    end

    it "sets the correct from address" do
      expect(mail.from).to eq(["tester@cc_curation_centre.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_text("has finished providing feedback on the plan")
    end

  end

  describe "#feedback_confirmation" do

    before do
      Branding.expects(:fetch).twice
              .with(:application, :name)
              .returns("DMP Test")
      create(:role, :creator, plan: plan, user: user)
    end

    let(:plan) { create(:plan) }

    let(:requestor) { create(:user) }

    let(:mail) { UserMailer.feedback_confirmation(user, plan, requestor) }

    let(:org) { requestor.org }

    it "sets the correct recipient address" do
       expect(mail.to).to eq([user.email])
    end

    it "sets the correct from address" do
      expect(mail.from).to eq(["tester@cc_curation_centre.org"])
    end

    context "when org has custom subject" do

      before do
        org.update(feedback_email_subject: "Test subject")
      end

      it "sets the correct subject" do
        expect(mail.subject).to eq("Test subject")
      end

    end

    context "when org has no custom subject" do

      it "shows the default subject" do
        expect(mail.subject).to eq("DMP Test: Your plan has been submitted for feedback")
      end

    end

    context "when org has custom message" do

      before do
        org.update(feedback_email_msg: "Test message")
      end

      it "sets the correct subject" do
        expect(mail.body.encoded).to have_text("Test message")
      end

    end

    context "when org has no custom message" do

      it "shows the default message" do
        expect(mail.subject).to eq("DMP Test: Your plan has been submitted for feedback")
      end

    end

  end

  describe "#plan_visibility" do

    before do
      Branding.expects(:fetch)
              .with(:application, :name)
              .returns("DMP Test")
      Branding.expects(:fetch)
              .with(:organisation, :helpdesk_email)
              .returns("noreply@dmptest.com")
      Branding.expects(:fetch)
              .with(:organisation, :contact_us_url)
              .returns("http://example.com")
      create(:role, :creator, plan: plan, user: user)
    end

    let(:plan) { create(:plan) }

    let(:mail) { UserMailer.plan_visibility(user, plan) }

    it "sets the correct subject" do
      expect(mail.subject).to eq("DMP Visibility Changed: #{plan.title}")
    end

    it "sets the correct recipient address" do
       expect(mail.to).to eq([user.email])
    end

    it "sets the correct from address" do
      expect(mail.from).to eq(["tester@cc_curation_centre.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_text("The plan #{plan.title} had its visibility changed to #{Plan::VISIBILITY_MESSAGE[plan.visibility.to_sym]}.")
    end

  end

  describe "#new_comment" do

    before do
      Branding.expects(:fetch)
              .with(:application, :name)
              .returns("DMP Test")
      Branding.expects(:fetch)
              .with(:organisation, :helpdesk_email)
              .returns("noreply@dmptest.com")
      Branding.expects(:fetch)
              .with(:organisation, :contact_us_url)
              .returns("http://example.com")
      create(:role, :creator, plan: plan, user: user)
    end

    let(:plan) { create(:plan) }

    let(:remover) { create(:user) }

    let(:mail) { UserMailer.new_comment(user, plan) }

    it "sets the correct subject" do
      expect(mail.subject).to eq("DMP Test: A new comment was added to #{plan.title}")
    end

    it "sets the correct recipient address" do
       expect(mail.to).to eq([user.email])
    end

    it "sets the correct from address" do
      expect(mail.from).to eq(["tester@cc_curation_centre.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to have_text("#{user.name(false)} has commented on the plan #{plan.title}")
    end

  end

  describe "#admin_privileges" do

    before do
      Branding.expects(:fetch)
              .with(:application, :name)
              .returns("DMP Test")
      Branding.expects(:fetch)
              .with(:organisation, :url)
              .returns("http://example.com/help-us")
      Branding.expects(:fetch)
              .with(:organisation, :helpdesk_email)
              .returns("helpdesk@example.com")

      Branding.expects(:fetch)
              .with(:organisation, :contact_us_url)
              .returns("http://example.com/contact-us")
    end

    let(:mail) { UserMailer.admin_privileges(user) }


    it "sets the correct subject" do
      expect(mail.subject).to eq("Administrator privileges granted in DMP Test")
    end

    it "sets the correct recipient address" do
       expect(mail.to).to eq([user.email])
    end

    it "sets the correct from address" do
      expect(mail.from).to eq(["tester@cc_curation_centre.org"])
    end

    it "includes a link to the help email" do
      expect(mail.body.encoded).to have_text("helpdesk@example.com")
    end

    it "includes a link to the contact us page" do
      expect(mail.body.encoded).to have_text("http://example.com/contact-us")
    end

    context "when user has perms" do

      before do
        user.perms << create(:perm)
      end

      it "lists the user's perms" do
        expect(mail.body.encoded).to have_text(Perm::NAME_AND_TEXT[user.perms.first.name.to_sym])
      end

    end

    context "when user has no perms" do

      it "tells the recipient they no longer have access" do
        expect(mail.body.encoded).to have_text("You have been revoked administrator privileges in")
      end

    end

  end

end
