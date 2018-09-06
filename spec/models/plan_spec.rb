require 'rails_helper'

describe Plan do

  context "validations" do
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_presence_of(:template) }

    it { is_expected.to allow_values(true, false).for(:feedback_requested) }

    it { is_expected.not_to allow_value(nil).for(:feedback_requested) }

    it { is_expected.to allow_values(true, false).for(:complete) }

    it { is_expected.not_to allow_value(nil).for(:complete) }
  end

  context "associations" do

    it { is_expected.to belong_to :template }


    it { is_expected.to have_many :phases }

    it { is_expected.to have_many :sections }

    it { is_expected.to have_many :questions }

    it { is_expected.to have_many :themes }

    it { is_expected.to have_many :answers }

    it { is_expected.to have_many :notes }

    it { is_expected.to have_many :roles }

    it { is_expected.to have_many :users }

    it { is_expected.to have_many :exported_plans }

    it { is_expected.to have_many :setting_objects }

  end

  describe ".publicly_visible" do

    subject { Plan.publicly_visible }

    context "when plan visibility is publicly_visible" do

      let!(:plan) { create(:plan, :publicly_visible) }

      it { is_expected.to include(plan) }

    end

    context "when plan visibility is organisationally_visible" do

      let!(:plan) { create(:plan, :organisationally_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is is_test" do

      let!(:plan) { create(:plan, :is_test) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is privately_visible" do

      let!(:plan) { create(:plan, :privately_visible) }

      it { is_expected.not_to include(plan) }

    end

  end

  describe ".organisationally_visible" do

    subject { Plan.organisationally_visible }

    context "when plan visibility is publicly_visible" do

      let!(:plan) { create(:plan, :publicly_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is organisationally_visible" do

      let!(:plan) { create(:plan, :organisationally_visible) }

      it { is_expected.to include(plan) }

    end

    context "when plan visibility is is_test" do

      let!(:plan) { create(:plan, :is_test) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is privately_visible" do

      let!(:plan) { create(:plan, :privately_visible) }

      it { is_expected.not_to include(plan) }

    end

  end

  describe ".privately_visible" do

    subject { Plan.privately_visible }

    context "when plan visibility is publicly_visible" do

      let!(:plan) { create(:plan, :publicly_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is organisationally_visible" do

      let!(:plan) { create(:plan, :organisationally_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is is_test" do

      let!(:plan) { create(:plan, :is_test) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is privately_visible" do

      let!(:plan) { create(:plan, :privately_visible) }

      it { is_expected.to include(plan) }

    end

  end

  describe ".organisationally_or_publicly_visible" do

    let!(:user) { create(:user) }

    subject { Plan.organisationally_or_publicly_visible(user) }

    context "when user is creator" do

      before do
        create(:role, :creator, user: user, plan: plan)
      end

      let!(:plan) { create(:plan, :publicly_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when user is administrator" do

      before do
        create(:role, :administrator, user: user, plan: plan)
      end

      let!(:plan) { create(:plan, :publicly_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when user is commenter" do

      before do
        create(:role, :commenter, user: user, plan: plan)
      end

      let!(:plan) { create(:plan, :publicly_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when user is editor" do

      before do
        create(:role, :editor, user: user, plan: plan)
      end

      let!(:plan) { create(:plan, :publicly_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is publicly_visible" do

      let!(:plan) { create(:plan, :publicly_visible) }

      xit "TODO: Fix this spec" do
        is_expected.to include(plan)
      end

    end

    context "when plan visibility is organisationally_visible" do

      let!(:plan) { create(:plan, :organisationally_visible) }

      xit "TODO: Fix this spec" do
        is_expected.to include(plan)
      end

    end

    context "when plan visibility is is_test" do

      let!(:plan) { create(:plan, :is_test) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is privately_visible" do

      let!(:plan) { create(:plan, :privately_visible) }

      it { is_expected.not_to include(plan) }

    end

  end

  describe ".is_test" do

    subject { Plan.is_test }

    context "when plan visibility is publicly_visible" do

      let!(:plan) { create(:plan, :publicly_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is organisationally_visible" do

      let!(:plan) { create(:plan, :organisationally_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is is_test" do

      let!(:plan) { create(:plan, :is_test) }

      it { is_expected.to include(plan) }

    end

    context "when plan visibility is privately_visible" do

      let!(:plan) { create(:plan, :privately_visible) }

      it { is_expected.not_to include(plan) }

    end

  end

  describe ".active" do

    let!(:plan) { create(:plan) }

    let!(:user) { create(:user) }

    subject { Plan.active(user) }

    context "where user role is active" do

      before do
        create(:role, :active, :creator, user: user, plan: plan)
      end

      it { is_expected.to include(plan) }

    end

    context "where user role is not active" do

      before do
        create(:role, :inactive, :creator, user: user, plan: plan)
      end

      it { is_expected.not_to include(plan) }

    end

    context "where user role is reviewer" do

      before do
        create(:role, :active, :reviewer, user: user, plan: plan)
      end

      it { is_expected.not_to include(plan) }

    end

  end

  describe ".load_for_phase" do

    let!(:template) { create(:template) }

    let!(:plan) { create(:plan, template: template) }

    let!(:phase) { create(:phase, template: template) }

    let!(:section) { create(:section, phase: phase) }

    let!(:question) { create(:question, section: section) }

    subject { Plan.load_for_phase(plan.id, phase.id) }

    context "when Plan ID is valid and Phase ID is valid child" do

      it "returns an Array" do
        expect(subject).to be_an(Array)
      end

      it "returns the Plan first" do
        expect(subject.first).to eql(plan)
      end

      it "returns the Phase second" do
        expect(subject.second).to eql(phase)
      end

    end

    context "when Plan ID is valid and Phase ID is not valid child" do

      let!(:phase) { create(:phase) }

      it "raises an exception" do
        # TODO: This is not ideal behaviour. Fix this.
        expect { subject }.to raise_error(NoMethodError)
      end

    end

    context "when Plan ID is not valid" do

      let!(:plan) { stub(id: 0) }

      it "raises an exception" do
        # TODO: This is not ideal behaviour. Fix this.
        expect { subject }.to raise_error(NoMethodError)
      end

    end

  end

  describe ".deep_copy" do

    let!(:plan) { create(:plan, answers: 2, guidance_groups: 2) }

    subject { Plan.deep_copy(plan) }

    it "prepends the title with 'Copy'" do
      expect(subject.title).to include("Copy")
    end

    it "copies the title from source" do
      expect(subject.title).to include(plan.title)
    end

    it "persists the record" do
      expect(subject).to be_persisted
    end

    it "creates new copies of the answers" do
      expect(subject.answers).to have(2).items
    end

    it "duplicates the guidance groups" do
      expect(subject.guidance_groups).to have(2).items
    end
  end

  describe ".search" do

    subject { Plan.search("foo") }

    context "when Plan title matches term" do

      let!(:plan)  { create(:plan, title: "foolike title") }

      it { is_expected.to include(plan) }

    end

    context "when Template title matches term" do

      let!(:template) { create(:template, title: "foolike title") }

      let!(:plan)  { create(:plan, template: template) }

      it { is_expected.to include(plan) }

    end

    context "when neither title matches term" do

      let!(:plan)  { create(:plan, description: "foolike desc") }

      it { is_expected.not_to include(plan) }

    end

  end

  describe "#answer" do

    let!(:plan) { create(:plan, answers: 1) }

    let!(:question) { create(:question) }

    subject { plan.answer(question.id, create_if_missing) }


    context "when create_if_missing is true and answer exists on the DB" do

      let!(:create_if_missing) { true }

      let!(:answer) { create(:answer, plan: plan, question: question) }

      it "returns the existing Answer" do
        expect(subject).to eql(answer)
      end

    end

    context "when create_if_missing is true and answer doesn't exist on the DB" do

      let!(:create_if_missing) { true }

      it "returns a new Answer" do
        expect(subject).to be_an(Answer)
      end

      it "doesn't persist the new Answer" do
        expect(subject).to be_new_record
      end

    end

    context "when create_if_missing is false and qid exists on the DB" do

      let!(:create_if_missing) { false }

      let!(:answer) { create(:answer, plan: plan, question: question) }

      it "returns the existing Answer" do
        expect(subject).to eql(answer)
      end

    end

    context "when create_if_missing is false and qid doesn't exist on the DB" do

      let!(:create_if_missing) { false }

      let!(:answer) { nil }

      it "returns nil" do
        expect(subject).to be_nil
      end

    end
  end

  describe "#guidance_group_options" do

    let!(:plan) { create(:plan) }

    subject { plan.guidance_group_options }

    before do
      @phase          = create(:phase, template: plan.template)
      @section        = create(:section, phase: @phase)
      @question       = create(:question, section: @section)
      @theme          = create(:theme)
      @guidance       = create(:guidance)
      @guidance_group = @guidance.guidance_group
      @question.themes << @theme
      @theme.guidances << @guidance
    end

    context "when guidance groups are unpublished" do

      before do
        @guidance_group.update(published: false)
      end

      it "excludes the guidance group from options" do
        expect(subject).not_to include(@guidance_group)
      end

    end

    context "when guidance groups are published" do

      it "includes the guidance group in options" do
        expect(subject).to include(@guidance_group)
      end

    end

  end

  describe "#request_feedback" do

    subject { plan.request_feedback(user) }

    let!(:org)  { create(:org, contact_email: nil) }

    let!(:user) { create(:user, org: org) }

    let!(:plan) { create(:plan) }

    before do
      # Create 2 Org admins for this Org.
      create_list(:user, 2, org: org).each do |user|
        user.perms << Perm.where(name: 'modify_guidance').first_or_create
      end
      ActionMailer::Base.deliveries = []
    end

    it "changes plan's feedback_requested value to true" do
      expect { subject }.to change {
        plan.reload.feedback_requested
      }.from(false).to(true)
    end

    it "doesn't send any emails" do
      expect { subject }.not_to change { ActionMailer::Base.deliveries.size }
    end

    context "when org contact_email present" do

      before do
        org.update!(contact_email: Faker::Internet.safe_email)
      end

      it "emails the admins" do
        expect { subject }.to change {
          ActionMailer::Base.deliveries.size
        }.by(1)
      end

    end

  end

  describe "#complete_feedback" do

    subject { plan.complete_feedback(user) }

    let!(:org)  { create(:org) }

    let!(:user) { create(:user, org: org) }

    let!(:admin) { create(:user) }

    let!(:template) { create(:template, phases: 2) }

    let!(:plan) { create(:plan, feedback_requested: true, template: template) }

    before do
      create(:role, :creator, plan: plan, user: user)
      # This person gets the email notification
      create(:role, :administrator, plan: plan, user: admin)
      create_list(:role, 2, :reviewer, plan: plan)
    end

    it "changes plan's feedback_requested value to false" do
      expect { subject }.to change {
        plan.reload.feedback_requested
      }.from(true).to(false)
    end

    it "destroys the reviewer Roles" do
      expect { subject }.to change { plan.roles.count }.by(-2)
    end

    it "doesn't send any emails" do
      User.any_instance.stubs(:get_preferences)
          .returns(:users => { :feedback_provided => false })
      expect { subject }.not_to change { ActionMailer::Base.deliveries.size }
    end

    context "when user feedback provided pref is true" do

      before do
        User.any_instance.stubs(:get_preferences)
            .returns(:users => { :feedback_provided => true })
      end

      it "emails the owners" do
        expect { subject }.to change {
          ActionMailer::Base.deliveries.size
        }.by(1)
      end

    end

  end

  describe "#guidance_by_question_as_hash" do



  end

  describe "#editable_by?" do

    let!(:user) { create(:user) }

    let!(:plan) { create(:plan) }

    subject { plan }

    context "when User has no Role for this Plan" do

      it { is_expected.not_to be_editable_by(user.id) }

    end

    context "when User is passed instead of User ID" do

      before do
        create(:role, :editor, plan: plan, user: user)
      end

      it { is_expected.to be_editable_by(user) }

    end

    context "when user Role :creator" do

      before do
        create(:role, :creator, plan: plan, user: user)
      end

      it { is_expected.not_to be_editable_by(user.id) }

    end

    context "when user Role :administrator" do

      before do
        create(:role, :administrator, plan: plan, user: user)
      end

      it { is_expected.not_to be_editable_by(user.id) }

    end

    context "when user Role :editor" do

      before do
        create(:role, :editor, plan: plan, user: user)
      end

      it { is_expected.to be_editable_by(user.id) }

    end

    context "when user Role :commenter" do

      before do
        create(:role, :commenter, plan: plan, user: user)
      end

      it { is_expected.not_to be_editable_by(user.id) }

    end

    context "when user Role :reviewer" do

      before do
        create(:role, :reviewer, plan: plan, user: user)
      end

      it { is_expected.not_to be_editable_by(user.id) }

    end

  end

  describe "#readable_by?" do

    let!(:plan) { create(:plan) }

    let!(:creator) do
      create(:user).tap { |u| create(:role, :creator, user: u, plan: plan) }
    end

    let!(:org) { creator.org }

    let!(:user) { create(:user, org: org) }

    subject { plan }

    context "when User is Super admin & system permission" do

      before do
        user.perms << create(:perm, name: "add_organisations")
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :super_admins_read_all)
                .returns(true)
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :org_admins_read_all)
                .returns(false)
      end

      it { is_expected.to be_readable_by(user) }

    end

    context "when User is Super admin & not system permission" do

      before do
        user.perms << create(:perm, name: "add_organisations")
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :super_admins_read_all)
                .returns(false)
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :org_admins_read_all)
                .returns(false)
      end

      it { is_expected.not_to be_readable_by(user) }

    end

    context "when User is Org admin & user is Org owner & system permission" do

      before do
        user.perms << create(:perm, name: "grant_permissions")
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :org_admins_read_all)
                .returns(true)
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :super_admins_read_all)
                .returns(false)
      end

      it { is_expected.to be_readable_by(user) }

    end

    context "when User is Org admin & user is Org owner & not system permission" do

      before do
        user.perms << create(:perm, name: "grant_permissions")
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :org_admins_read_all)
                .returns(false)
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :super_admins_read_all)
                .returns(false)
      end

      it { is_expected.not_to be_readable_by(user) }

    end

    context "when User is Org admin & user not Org owner & system permission" do

      before do
        user.update(org: create(:org))

        user.perms << create(:perm, name: "grant_permissions")
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :org_admins_read_all)
                .returns(true)
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :super_admins_read_all)
                .returns(false)
      end

      it { is_expected.not_to be_readable_by(user) }

    end

    context "when User is Org admin & user not Org owner & not system permission" do

      before do
        user.update(org: create(:org))

        user.perms << create(:perm, name: "grant_permissions")
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :org_admins_read_all)
                .returns(false)
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :super_admins_read_all)
                .returns(false)
      end

      it { is_expected.not_to be_readable_by(user) }

    end

    context "when User not Org admin & user not Org owner & system permission" do

      before do
        user.update(org: create(:org))
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :org_admins_read_all)
                .returns(true)
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :super_admins_read_all)
                .returns(false)
      end

      it { is_expected.not_to be_readable_by(user) }

    end

    context "when User not Org admin & user not Org owner & not system permission" do

      before do
        user.update(org: create(:org))
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :org_admins_read_all)
                .returns(false)
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :super_admins_read_all)
                .returns(false)
      end

      it { is_expected.not_to be_readable_by(user) }

    end

    context "when User has commenter role" do

      before do
        create(:role, :commenter, user: user, plan: plan)
      end

      it { is_expected.to be_readable_by(user) }

    end

    context "when User doesn't have commenter Role" do

      it { is_expected.not_to be_readable_by(user) }

    end

  end

  describe "#commentable_by?" do

    let!(:user) { create(:user) }

    let!(:plan) { create(:plan) }

    subject { plan }

    context "when User has no Role for this Plan" do

      it { is_expected.not_to be_commentable_by(user.id) }

    end

    context "when User is passed instead of User ID" do

      before do
        create(:role, :commenter, plan: plan, user: user)
      end

      it { is_expected.to be_commentable_by(user) }

    end

    context "when user Role :creator" do

      before do
        create(:role, :creator, plan: plan, user: user)
      end

      it { is_expected.not_to be_commentable_by(user.id) }

    end

    context "when user Role :administrator" do

      before do
        create(:role, :administrator, plan: plan, user: user)
      end

      it { is_expected.not_to be_commentable_by(user.id) }

    end

    context "when user Role :editor" do

      before do
        create(:role, :editor, plan: plan, user: user)
      end

      it { is_expected.not_to be_commentable_by(user.id) }

    end

    context "when user Role :commenter" do

      before do
        create(:role, :commenter, plan: plan, user: user)
      end

      it { is_expected.to be_commentable_by(user.id) }

    end

    context "when user Role :reviewer" do

      before do
        create(:role, :reviewer, plan: plan, user: user)
      end

      it { is_expected.not_to be_commentable_by(user.id) }

    end

  end

  describe "#administerable_by?" do

    let!(:user) { create(:user) }

    let!(:plan) { create(:plan) }

    subject { plan }

    context "when User has no Role for this Plan" do

      it { is_expected.not_to be_administerable_by(user.id) }

    end

    context "when User is passed instead of User ID" do

      before do
        create(:role, :administrator, plan: plan, user: user)
      end

      it { is_expected.to be_administerable_by(user) }

    end

    context "when user Role :creator" do

      before do
        create(:role, :creator, plan: plan, user: user)
      end

      it { is_expected.not_to be_administerable_by(user.id) }

    end

    context "when user Role :administrator" do

      before do
        create(:role, :administrator, plan: plan, user: user)
      end

      it { is_expected.to be_administerable_by(user.id) }

    end

    context "when user Role :editor" do

      before do
        create(:role, :editor, plan: plan, user: user)
      end

      it { is_expected.not_to be_administerable_by(user.id) }

    end

    context "when user Role :commenter" do

      before do
        create(:role, :commenter, plan: plan, user: user)
      end

      it { is_expected.not_to be_administerable_by(user.id) }

    end

    context "when user Role :reviewer" do

      before do
        create(:role, :reviewer, plan: plan, user: user)
      end

      it { is_expected.not_to be_administerable_by(user.id) }

    end

  end

  describe "#reviewable_by?" do

    let!(:user) { create(:user) }

    let!(:plan) { create(:plan) }

    subject { plan }

    context "when User has no Role for this Plan" do

      it { is_expected.not_to be_reviewable_by(user.id) }

    end

    context "when User is passed instead of User ID" do

      before do
        create(:role, :reviewer, plan: plan, user: user)
      end

      it { is_expected.to be_reviewable_by(user) }

    end

    context "when user Role :creator" do

      before do
        create(:role, :creator, plan: plan, user: user)
      end

      it { is_expected.not_to be_reviewable_by(user.id) }

    end

    context "when user Role :administrator" do

      before do
        create(:role, :administrator, plan: plan, user: user)
      end

      it { is_expected.not_to be_reviewable_by(user.id) }

    end

    context "when user Role :editor" do

      before do
        create(:role, :editor, plan: plan, user: user)
      end

      it { is_expected.not_to be_reviewable_by(user.id) }

    end

    context "when user Role :commenter" do

      before do
        create(:role, :commenter, plan: plan, user: user)
      end

      it { is_expected.not_to be_reviewable_by(user.id) }

    end

    context "when user Role :reviewer" do

      before do
        create(:role, :reviewer, plan: plan, user: user)
      end

      it { is_expected.to be_reviewable_by(user.id) }

    end

  end

  describe "#assign_creator" do

    let!(:plan) { create(:plan) }

    let!(:user) { create(:user) }

    subject { plan.assign_creator(user.id) }

    it "creates a role for the user and plan" do
      expect { subject }.to change { user.roles.count }.by(1)
    end

  end

  describe "#latest_update" do

    let!(:plan) { create(:plan, updated_at: 5.minutes.ago) }

    subject { plan.latest_update.to_i }

    context "when plan updated_at is latest" do

      before do
        create_list(:phase, 2, template: plan.template,
                               updated_at: 6.minutes.ago)
      end

      it "returns the plan's updated_at value" do
        is_expected.to be_within(5.seconds).of(5.minutes.ago.to_i)
      end

    end

    context "when plan has phases updated_at latest" do

      before do
        create_list(:phase, 2, template: plan.template)
      end

      it "returns the plan's updated_at value" do
        is_expected.to be_within(5.seconds).of(Time.current.to_i)
      end

    end

  end

  describe "#name" do

    let!(:plan) { build(:plan, title: "Foo bar") }

    it "returns the title" do
      expect(plan.name).to eql("Foo bar")
    end

  end

  describe "#owner" do

    subject { plan.owner }

    let!(:plan) { create(:plan) }

    let!(:user) { create(:user) }

    context "when user Role is :creator" do

      before do
        create(:role, :creator, plan: plan, user: user)
      end

      it { is_expected.to eql(user) }

    end

    context "when user Role is :administrator" do

      before do
        create(:role, :administrator, plan: plan, user: user)
      end

      it { is_expected.to be_nil }

    end

    context "when user Role is :editor" do

      before do
        create(:role, :editor, plan: plan, user: user)
      end

      it { is_expected.to be_nil }

    end

    context "when user Role is :commenter" do

      before do
        create(:role, :commenter, plan: plan, user: user)
      end

      it { is_expected.to be_nil }

    end

    context "when user Role is :reviewer" do

      before do
        create(:role, :reviewer, plan: plan, user: user)
      end

      it { is_expected.to be_nil }

    end

  end

  describe "#shared?" do

    subject { plan.shared? }

    let!(:plan) { create(:plan) }

    context "when roles are: creator" do

      before do
        create(:role, :creator, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: administrator" do

      before do
        create(:role, :administrator, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, administrator" do

      before do
        create(:role, :creator, :administrator, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: editor" do

      before do
        create(:role, :editor, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, editor" do

      before do
        create(:role, :creator, :editor, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: administrator, editor" do

      before do
        create(:role, :administrator, :editor, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, editor, administrator" do

      before do
        create(:role, :creator, :editor, :administrator, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: commenter" do

      before do
        create(:role, :commenter, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, commenter" do

      before do
        create(:role, :creator, :commenter, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: administrator, commenter" do

      before do
        create(:role, :administrator, :commenter, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, administrator, commenter" do

      before do
        create(:role, :creator, :administrator, :commenter, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: editor, commenter" do

      before do
        create(:role, :editor, :commenter, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, editor, commenter" do

      before do
        create(:role, :creator, :editor, :commenter, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: administrator, editor, commenter" do

      before do
        create(:role, :administrator, :editor, :commenter, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, administrator, editor, commenter" do

      before do
        create(:role, :creator, :administrator, :editor, :commenter, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: reviewer" do

      before do
        create(:role, :reviewer, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, reviewer" do

      before do
        create(:role, :creator, :reviewer, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: administrator, reviewer" do

      before do
        create(:role, :administrator, :reviewer, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, administrator, reviewer" do

      before do
        create(:role, :creator, :administrator, :reviewer, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: editor, reviewer" do

      before do
        create(:role, :editor, :reviewer, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, editor, reviewer" do

      before do
        create(:role, :creator, :editor, :reviewer, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: administrator, editor, reviewer" do

      before do
        create(:role, :administrator, :editor, :reviewer, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, editor, administrator, reviewer" do

      before do
        create(:role, :creator, :editor, :administrator, :reviewer, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: commenter, reviewer" do

      before do
        create(:role, :commenter, :reviewer, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, commenter, reviewer" do

      before do
        create(:role, :creator, :commenter, :reviewer, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: administrator, commenter, reviewer" do

      before do
        create(:role, :administrator, :commenter, :reviewer, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, administrator, commenter, reviewer" do

      before do
        create(:role, :creator, :administrator, :commenter, :reviewer, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: editor, commenter, reviewer" do

      before do
        create(:role, :editor, :commenter, :reviewer, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, editor, commenter, reviewer" do

      before do
        create(:role, :creator, :editor, :commenter, :reviewer, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

    context "when roles are: administrator, editor, commenter, reviewer" do

      before do
        create(:role, :administrator, :editor, :commenter, :reviewer, plan: plan)
      end

      it { is_expected.to eql(true) }

    end

    context "when roles are: creator, administrator, editor, commenter, reviewer" do

      before do
        create(:role, :creator, :administrator, :editor, :commenter, :reviewer, plan: plan)
      end

      it { is_expected.to eql(false) }

    end

  end

  describe "#owner_and_coowners" do

    let!(:user) { create(:user) }

    let!(:plan) { create(:plan) }

    subject { plan.owner_and_coowners }

    context "when role is creator" do

      before do
        create(:role, :creator, user: user, plan: plan)
      end

      it { is_expected.to include(user) }

    end

    context "when role is administrator" do

      before do
        create(:role, :administrator, user: user, plan: plan)
      end

      it { is_expected.to include(user) }

    end

    context "when role is editor" do

      before do
        create(:role, :editor, user: user, plan: plan)
      end

      it { is_expected.not_to include(user) }

    end

    context "when role is commenter" do

      before do
        create(:role, :commenter, user: user, plan: plan)
      end

      it { is_expected.not_to include(user) }

    end

    context "when role is reviewer" do

      before do
        create(:role, :reviewer, user: user, plan: plan)
      end

      it { is_expected.not_to include(user) }

    end

  end

  describe "#num_answered_questions" do

    let!(:template) { create(:template) }

    let!(:plan) { create(:plan, template: template) }

    subject { plan.num_answered_questions }

    before do
      @phase     = create(:phase, template: template)
      @section   = create(:section, phase: @phase)
      @questions = create_list(:question, 3, :textarea, section: @section)
      # 2 valid answers
      @questions.first(2).each do |question|
        create(:answer, question: question, plan: plan)
      end
      # 1 valid answers
      @questions.last(1).each do |question|
        create(:answer, question: question, plan: plan, text: nil)
      end
    end

    it "returns the number of questions with valid answers" do
      expect(subject).to eql(2)
    end

  end

  describe "#num_questions" do

    let!(:template) { create(:template) }

    let!(:plan) { create(:plan, template: template) }

    subject { plan.num_questions }

    before do
      create_list(:phase, 2, template: template) do |phase|
        create_list(:section, 2, phase: phase) do |section|
          create_list(:question, 3, section: section)
        end
      end
    end

    it "returns the number of questions belonging to this plan's sections" do
      expect(subject).to eql(12)
    end

  end

  describe "#visibility_allowed?" do

    let!(:template) { create(:template) }

    let!(:plan) { create(:plan, template: template) }

    subject { plan.visibility_allowed? }

    before do
      @phase     = create(:phase, template: template)
      @section   = create(:section, phase: @phase)
      @questions = create_list(:question, 4, :textarea, section: @section)
      @questions.take(3).each do |question|
        create(:answer, question: question, plan: plan)
      end
    end

    context "when requisite number of questions answered" do

      before do
        Rails.application.config.default_plan_percentage_answered = 75
      end

      it { is_expected.to eql(true) }

    end

    context "when requisite number of questions not answered" do

      before do
        Rails.application.config.default_plan_percentage_answered = 76
      end

      it { is_expected.to eql(false) }
    end

  end

  describe "#question_exists?" do

    subject { plan.question_exists?(question.id) }

    context "when Question with ID and Plan exists" do

      let!(:question) { create(:question) }

      let!(:plan) { create(:plan, template: question.section.phase.template) }

      it { is_expected.to eql(true) }

    end

    context "when Question with ID and Plan don't exist" do

      let!(:question) { create(:question) }

      let!(:plan) { create(:plan) }

      it { is_expected.to eql(false) }

    end

  end

  describe "#no_questions_matches_no_answers?" do

    let!(:plan) { create(:plan) }

    subject { plan.no_questions_matches_no_answers? }

    context "when has no answers" do

      it { is_expected.to eql(true) }

    end

    context "when has answers that are not valid" do

      let!(:question) { create(:question, :textarea) }

      before do
        create_list(:answer, 1, text: "", plan: plan, question: question)
      end

      it { is_expected.to eql(true) }

    end

    context "when has answers that are valid" do

      let!(:question) { create(:question, :textarea) }

      before do
        create_list(:answer, 1, plan: plan, question: question)
      end

      it { is_expected.to eql(false) }

    end
  end

end
