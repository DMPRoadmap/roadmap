require 'rails_helper'

describe Plan do

  include RolesHelper
  include TemplateHelper

  context "validations" do
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_presence_of(:template) }

    it { is_expected.to allow_values(true, false).for(:feedback_requested) }

    it { is_expected.not_to allow_value(nil).for(:feedback_requested) }

    it { is_expected.to allow_values(true, false).for(:complete) }

    it { is_expected.not_to allow_value(nil).for(:complete) }

    describe "dates" do
      before(:each) do
        @plan = build(:plan)
      end

      it "allows start_date to be nil" do
        @plan.start_date = nil
        @plan.end_date = Time.now + 3.days
        expect(@plan.valid?).to eql(true)
      end
      it "allows end_date to be nil" do
        @plan.start_date = Time.now + 3.days
        @plan.end_date = nil
        expect(@plan.valid?).to eql(true)
      end
      it "does not allow end_date to come before start_date" do
        @plan.start_date = Time.now + 3.days
        @plan.end_date = Time.now
        expect(@plan.valid?).to eql(false)
      end
    end

  end

  context "associations" do

    it { is_expected.to belong_to :template }

    it { is_expected.to belong_to :org }

    it { is_expected.to belong_to :funder }

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

    it { is_expected.to have_many(:identifiers) }

    it { is_expected.to have_many(:contributors) }

  end

  describe ".publicly_visible" do

    subject { Plan.publicly_visible }

    context "when plan visibility is publicly_visible" do

      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.to include(plan) }

    end

    context "when plan visibility is organisationally_visible" do

      let!(:plan) { create(:plan, :creator, :organisationally_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is is_test" do

      let!(:plan) { create(:plan, :creator, :is_test) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is privately_visible" do

      let!(:plan) { create(:plan, :creator, :privately_visible) }

      it { is_expected.not_to include(plan) }

    end

  end

  describe ".organisationally_visible" do

    subject { Plan.organisationally_visible }

    context "when plan visibility is publicly_visible" do

      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is organisationally_visible" do

      let!(:plan) { create(:plan, :creator, :organisationally_visible) }

      it { is_expected.to include(plan) }

    end

    context "when plan visibility is is_test" do

      let!(:plan) { create(:plan, :creator, :is_test) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is privately_visible" do

      let!(:plan) { create(:plan, :creator, :privately_visible) }

      it { is_expected.not_to include(plan) }

    end

  end

  describe ".privately_visible" do

    subject { Plan.privately_visible }

    context "when plan visibility is publicly_visible" do

      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is organisationally_visible" do

      let!(:plan) { create(:plan, :creator, :organisationally_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is is_test" do

      let!(:plan) { create(:plan, :creator, :is_test) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is privately_visible" do

      let!(:plan) { create(:plan, :creator, :privately_visible) }

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

      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when user is administrator" do

      before do
        create(:role, :administrator, user: user, plan: plan)
      end

      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when user is commenter" do

      before do
        create(:role, :commenter, user: user, plan: plan)
      end

      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when user is editor" do

      before do
        create(:role, :editor, user: user, plan: plan)
      end

      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is publicly_visible" do

      before do
        new_user = create(:user, org: user.org)
        create(:role, :creator, :administrator, :editor, :commenter,
                      user: new_user, plan: plan)
      end

      let!(:template) { build_template(1, 1, 1) }
      let!(:plan) { create(:plan, :creator, :organisationally_visible, template: template) }
      let!(:answer) { create(:answer, plan: plan,
                             question: template.phases.first.sections.first.questions.first) }

      it "includes publicly_visible plans" do
        is_expected.to include(plan)
      end

    end

    context "when plan visibility is organisationally_visible" do

      before do
        new_user = create(:user, org: user.org)
        create(:role, :creator, :administrator, :editor, :commenter,
                      user: new_user, plan: plan)
      end

      let!(:template) { build_template(1, 1, 1) }
      let!(:plan) { create(:plan, :creator, :organisationally_visible, template: template) }
      let!(:answer) { create(:answer, plan: plan,
                             question: template.phases.first.sections.first.questions.first) }

      it "includes organisationally_visible plans" do
        is_expected.to include(plan)
      end

    end

    context "when plan is not complete" do

      before do
        new_user = create(:user, org: user.org)
        create(:role, :creator, :administrator, :editor, :commenter,
                      user: new_user, plan: plan)
      end

      let!(:plan) { create(:plan, :creator, :organisationally_visible) }

      it "includes organisationally_visible plans" do
        is_expected.not_to include(plan)
      end

    end

    context "when plan visibility is is_test" do

      let!(:plan) { create(:plan, :creator, :is_test) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is privately_visible" do

      let!(:plan) { create(:plan, :creator, :privately_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan has no active roles" do

      let!(:plan) { build_plan }

      it "should not be included" do
        plan.roles.inject{ |r| r.deactivate! }
        is_expected.to_not include(plan)
      end

    end

  end

  describe ".is_test" do

    subject { Plan.is_test }

    context "when plan visibility is publicly_visible" do

      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is organisationally_visible" do

      let!(:plan) { create(:plan, :creator, :organisationally_visible) }

      it { is_expected.not_to include(plan) }

    end

    context "when plan visibility is is_test" do

      let!(:plan) { create(:plan, :creator, :is_test) }

      it { is_expected.to include(plan) }

    end

    context "when plan visibility is privately_visible" do

      let!(:plan) { create(:plan, :creator, :privately_visible) }

      it { is_expected.not_to include(plan) }

    end

  end

  describe ".active" do

    let!(:plan) { create(:plan, :creator) }

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

  end

  describe ".load_for_phase" do

    let!(:template) { create(:template) }

    let!(:plan) { create(:plan, :creator, template: template) }

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

    let!(:plan) { create(:plan, :creator, answers: 2, guidance_groups: 2,
                         feedback_requested: true) }

    subject { Plan.deep_copy(plan) }

    it "prepends the title with 'Copy'" do
      expect(subject.title).to include("Copy")
    end

    it "sets feedback_requested to false" do
      expect(subject.feedback_requested).to eql(false)
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

      let!(:plan)  { create(:plan, :creator, title: "foolike title") }

      it { is_expected.to include(plan) }

    end

    context "when Template title matches term" do

      let!(:template) { create(:template, title: "foolike title") }

      let!(:plan)  { create(:plan, :creator, template: template) }

      it { is_expected.to include(plan) }

    end

    context "when Organisation name matches term" do

      let!(:plan)  { create(:plan, :creator, description: "foolike desc") }

      let!(:org) { create(:org, name: 'foolike name') }

      before do
        user = plan.owner
        user.org = org
        user.save
      end

      it "returns organisation name" do
        expect(subject).to include(plan)
      end

    end

    # TODO: Add this one in once we are able to easily do LEFT JOINs in Rails 5
    context "when Contributor name matches term" do
      let!(:plan) { create(:plan, :creator, description: "foolike desc") }
      let!(:contributor) { create(:contributor, plan: plan, name: "Dr. Foo Bar") }

      xit "returns contributor name" do
        expect(subject).to include(plan)
      end
    end

    context "when neither title matches term" do

      let!(:plan)  { create(:plan, :creator, description: "foolike desc") }

      it { is_expected.not_to include(plan) }

    end


  end

  describe ".stats_filter" do

    subject { Plan.all.stats_filter }

    context "when plan visibility is test" do
      let!(:plan) { create(:plan, :creator, :is_test) }

      it { is_expected.not_to include(plan) }
    end

    context "when plan visibility is not test" do
      let!(:p1)  { create(:plan, :creator, :publicly_visible) }
      let!(:p2)  { create(:plan, :creator, :privately_visible) }
      let!(:p3)  { create(:plan, :creator, :organisationally_visible) }

      it { is_expected.to include(p1) }
      it { is_expected.to include(p2) }
      it { is_expected.to include(p3) }
    end

  end

  describe "#answer" do

    let!(:plan) { create(:plan, :creator, answers: 1) }

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

    let!(:plan) { create(:plan, :creator) }

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

    let!(:plan) { create(:plan, :creator) }

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

    let!(:plan) { create(:plan, feedback_requested: true,
                                template: template) }

    before do
      create(:role, :creator, plan: plan, user: user)
      # This person gets the email notification
      create(:role, :administrator, plan: plan, user: admin)
    end

    it "changes plan's feedback_requested value to false" do
      expect { subject }.to change {
        plan.reload.feedback_requested
      }.from(true).to(false)
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
        }.by(2)
      end

    end

  end

  describe "#guidance_by_question_as_hash" do

  end

  describe "#editable_by?" do

    let!(:plan) { build_plan(true, true, true) }

    subject { plan }

    it "when role is inactive" do
      role = subject.roles.editor.first
      role.deactivate!
      user = role.user
      expect(subject.editable_by?(user.id)).to eql(false)
    end

    it "when user is a creator" do
      # All creators should be able to edit
      subject.roles.creator.pluck(:user_id).each do |user_id|
        expect(subject.editable_by?(user_id)).to eql(true)
      end
    end

    it "when user is a administrator" do
      # All administrators (aka coowners) should be able to edit
      subject.roles.administrator.pluck(:user_id).each do |user_id|
        expect(subject.editable_by?(user_id)).to eql(true)
      end
    end

    it "when user is a editor" do
      # All editors should be able to edit
      subject.roles.editor.pluck(:user_id).each do |user_id|
        expect(subject.editable_by?(user_id)).to eql(true)
      end
    end

    it "when user is a commenter" do
      # Commenters should only be able to edit if they are also
      # a creator, administrator or editor
      subject.roles.commenter.each do |role|
        expect(subject.editable_by?(role.user.id)).to eql(role.editor?)
      end
    end

  end

  describe "#readable_by?" do

    let!(:user) { create(:user, org: create(:org)) }
    let!(:plan) { build_plan(true, true, true) }

    subject { plan }

    context "config allows for admin viewing" do

      it "super admins" do
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :super_admins_read_all)
                .returns(true)

        user.perms << create(:perm, name: "add_organisations")
        expect(subject.readable_by?(user.id)).to eql(true)
      end

      it "org admins" do
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :org_admins_read_all)
                .returns(true)
        user.org_id = plan.owner.org_id
        user.save
        user.perms << create(:perm, name: "modify_guidance")
        expect(subject.readable_by?(user.id)).to eql(true)
      end
    end

    context "config does not allow admin viewing" do

      before(:each) do
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :org_admins_read_all)
                .returns(false)
      end

      it "super admins" do
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :super_admins_read_all)
                .returns(false)

        user.perms << create(:perm, name: "add_organisations")
        expect(subject.readable_by?(user.id)).to eql(false)
      end

      it "org admins" do
        user.perms << create(:perm, name: "modify_guidance")
        expect(subject.readable_by?(user.id)).to eql(false)
      end
    end

    context "non-admin user" do

      it "when role is inactive" do
        role = subject.roles.commenter.first
        role.deactivate!
        user = role.user
        expect(subject.readable_by?(user.id)).to eql(false)
      end

      it "when user is a creator" do
        # All creators should be able to read
        subject.roles.creator.pluck(:user_id).each do |user_id|
          expect(subject.readable_by?(user_id)).to eql(true)
        end
      end

      it "when user is a administrator" do
        # All administrators should be able to read
        subject.roles.administrator.pluck(:user_id).each do |user_id|
          expect(subject.readable_by?(user_id)).to eql(true)
        end
      end

      it "when user is a editor" do
        # All editors should be able to read
        subject.roles.editor.pluck(:user_id).each do |user_id|
          expect(subject.readable_by?(user_id)).to eql(true)
        end
      end

      it "when user is a commenter" do
        # All commenters should be able to read
        subject.roles.commenter.pluck(:user_id).each do |user_id|
          expect(subject.readable_by?(user_id)).to eql(true)
        end
      end

      context "When user is a reviewer" do
        before do
          user.org = plan.owner.org
          user.save
          user.perms << create(:perm, :review_org_plans)
        end

        it "when user is a reviewer and feedback requested" do
          # All reviewers of the same org should be able to comment
          plan.feedback_requested = true
          plan.save
          expect(subject.readable_by?(user.id)).to eql(true)
        end

        it "when user is a reviewer and feedback not requested" do
          Branding.expects(:fetch)
                  .with(:service_configuration, :plans, :org_admins_read_all)
                  .returns(false)

          plan.feedback_requested = false
          plan.save
          expect(subject.readable_by?(user.id)).to eql(false)
        end

        it "when user is a reviewer of a different org and feedback requested" do
          # reviewers of other orgs should have no access
          user.org = create(:org)
          user.save
          user.perms << create(:perm, :review_org_plans)
          plan.feedback_requested = true
          plan.save
          expect(subject.readable_by?(user.id)).to eql(false)
        end
      end

      it "when user is not reviewer, has no roles on the plan and feedback requested" do
        # All reviewers should be able to comment
        user.org = plan.owner.org
        user.save
        plan.feedback_requested = true
        plan.save
        expect(subject.readable_by?(user.id)).to eql(false)
      end
    end

    context "explicit sharing does not conflict with admin-viewing" do

      it "super admins" do
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :super_admins_read_all)
                .at_most_once
                .returns(false)

        user.perms << create(:perm, name: "add_organisations")
        role = subject.roles.commenter.first
        role.user_id = user.id
        role.save!

        expect(subject.readable_by?(user.id)).to eql(true)
      end

      it "org admins" do
        Branding.expects(:fetch)
                .with(:service_configuration, :plans, :org_admins_read_all)
                .at_most_once
                .returns(false)

        user.perms << create(:perm, name: "modify_guidance")
        role = subject.roles.commenter.first
        role.user_id = user.id
        role.save!

        expect(subject.readable_by?(user.id)).to eql(true)
      end
    end
  end

  describe "#commentable_by?" do

    let!(:plan) { build_plan(true, true, true) }

    subject { plan }

    it "when role is inactive" do
      role = subject.roles.commenter.first
      role.deactivate!
      user = role.user
      expect(subject.commentable_by?(user.id)).to eql(false)
    end

    it "when user is a creator" do
      # All creators should be able to comment
      subject.roles.creator.pluck(:user_id).each do |user_id|
        expect(subject.commentable_by?(user_id)).to eql(true)
      end
    end

    it "when user is a administrator" do
      # All administrators should be able to comment
      subject.roles.administrator.pluck(:user_id).each do |user_id|
        expect(subject.commentable_by?(user_id)).to eql(true)
      end
    end

    it "when user is a editor" do
      # All editors should be able to comment
      subject.roles.editor.pluck(:user_id).each do |user_id|
        expect(subject.commentable_by?(user_id)).to eql(true)
      end
    end

    it "when user is a commenter" do
      # All commenters should be able to comment
      subject.roles.commenter.pluck(:user_id).each do |user_id|
        expect(subject.commentable_by?(user_id)).to eql(true)
      end
    end

    let(:user) { create(:user) }

    context "when user is a reviewer" do

      before do
        user.org = plan.owner.org
        user.save
        user.perms << create(:perm, :review_org_plans)
      end
      it "of the same org and feedback requested" do
        # All reviewers of the same org should be able to comment
        plan.feedback_requested = true
        plan.save
        expect(subject.commentable_by?(user.id)).to eql(true)
      end

      it "of the same org and feedback not requested" do
        plan.feedback_requested = false
        plan.save
        expect(subject.commentable_by?(user.id)).to eql(false)
      end

      it "of a different org and feedback requested" do
        # All reviewers of other orgs should not be able to comment
        user.org = create(:org)
        user.save
        # re-add permissions as org-admins will have these removed on save
        user.perms << create(:perm, :review_org_plans)
        plan.feedback_requested = true
        plan.save
        expect(subject.commentable_by?(user.id)).to eql(false)
      end

    end

    it "when user is not reviewer, has no roles on the plan and feedback requested" do
      # All reviewers should be able to comment
      user.org = plan.owner.org
      user.save
      plan.feedback_requested = true
      plan.save
      expect(subject.commentable_by?(user.id)).to eql(false)
    end

  end

  describe "#administerable_by?" do

    let!(:plan) { build_plan(true, true, true) }

    subject { plan }

    it "when role is inactive" do
      role = subject.roles.administrator.first
      role.deactivate!
      user = role.user
      expect(subject.administerable_by?(user.id)).to eql(false)
    end

    it "when user is a creator" do
      # All creators should be able to administer
      subject.roles.creator.pluck(:user_id).each do |user_id|
        expect(subject.administerable_by?(user_id)).to eql(true)
      end
    end

    it "when user is a administrator" do
      # All administrators should be able to administer
      subject.roles.administrator.pluck(:user_id).each do |user_id|
        expect(subject.administerable_by?(user_id)).to eql(true)
      end
    end

    it "when user is a editor" do
      # Editors should only be able to administer if they are also
      # a creator or administrator
      subject.roles.editor.each do |role|
        expect(subject.administerable_by?(role.user.id)).to eql(role.administrator?)
      end
    end

    it "when user is a commenter" do
      # Commenters should only be able to administer if they are also
      # a creator or administrator
      subject.roles.commenter.each do |role|
        expect(subject.administerable_by?(role.user.id)).to eql(role.administrator?)
      end
    end

  end

  describe "#reviewable_by?" do

    let!(:plan) { build_plan(true, true, true) }
    let!(:user) { create(:user) }

    before do
      plan.feedback_requested = true
      plan.save
      create(:perm, :review_org_plans)
    end

    subject { plan }

    it "when user is not a reviewer" do
      expect(subject.reviewable_by?(user.id)).to eql(false)
    end

    it "when user is a reviewer" do
      user.org = plan.owner.org
      user.save
      user.perms << Perm.review_plans
      expect(subject.owner.org).to eql(user.org)
      expect(user.can_review_plans?).to eql(true)
      expect(plan.feedback_requested?).to eql(true)
      expect(subject.reviewable_by?(user.id)).to eql(true)
    end

  end

  describe "#latest_update" do

    let!(:plan) { create(:plan, :creator, updated_at: 5.minutes.ago) }

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

    let!(:plan) { build(:plan, :creator, title: "Foo bar") }

    it "returns the title" do
      expect(plan.name).to eql("Foo bar")
    end

  end

  describe "#owner" do

    let!(:plan) { build_plan(true, true, true) }

    subject { plan }

    it "is the creator" do
      user = subject.roles.creator.first.user
      expect(subject.owner).to eql(user)
    end

    it "is the administrator if there is no creator" do
      subject.roles.creator.first.deactivate!
      user = subject.roles.where(active: true).administrator.first.user
      expect(subject.owner).to eql(user)
    end

  end

  describe "#add_user" do

    let!(:user) { create(:user, org: create(:org)) }
    let!(:plan) { build_plan }

    subject { plan }

    it "returns false if user does not exist" do
      expect(subject.add_user!(326465)).to eql(false)
    end

    it "adds the creator" do
      expect(subject.add_user!(user.id, :creator)).to eql(true)
      role = Role.find_by(user_id: user.id, plan_id: subject.id)
      expect(role.creator?).to eql(true)
      expect(role.administrator?).to eql(true)
      expect(role.editor?).to eql(true)
      expect(role.commenter?).to eql(true)
      expect(role.reviewer?).to eql(false)
    end

    it "adds the administrator" do
      expect(subject.add_user!(user.id, :administrator)).to eql(true)
      role = Role.find_by(user_id: user.id, plan_id: subject.id)
      expect(role.creator?).to eql(false)
      expect(role.administrator?).to eql(true)
      expect(role.editor?).to eql(true)
      expect(role.commenter?).to eql(true)
      expect(role.reviewer?).to eql(false)
    end

    it "adds the editor" do
      expect(subject.add_user!(user.id, :editor)).to eql(true)
      role = Role.find_by(user_id: user.id, plan_id: subject.id)
      expect(role.creator?).to eql(false)
      expect(role.administrator?).to eql(false)
      expect(role.editor?).to eql(true)
      expect(role.commenter?).to eql(true)
      expect(role.reviewer?).to eql(false)
    end

    it "adds the commenter" do
      expect(subject.add_user!(user.id, :commenter)).to eql(true)
      role = Role.find_by(user_id: user.id, plan_id: subject.id)
      expect(role.creator?).to eql(false)
      expect(role.administrator?).to eql(false)
      expect(role.editor?).to eql(false)
      expect(role.commenter?).to eql(true)
      expect(role.reviewer?).to eql(false)
    end

    it "defaults to commenter if access_level is not a known symbol" do
      expect(subject.add_user!(user.id)).to eql(true)
      role = Role.find_by(user_id: user.id, plan_id: subject.id)
      expect(role.creator?).to eql(false)
      expect(role.administrator?).to eql(false)
      expect(role.editor?).to eql(false)
      expect(role.commenter?).to eql(true)
      expect(role.reviewer?).to eql(false)
    end

  end

  describe "#shared?" do

    it "is not shared if the only user is the creator" do
      plan = build_plan
      expect(plan.shared?).to eql(false)
    end

    it "is shared if the plan has an administrator" do
      plan = build_plan(true, false, false)
      expect(plan.shared?).to eql(true)
    end

    it "is shared if the plan has an editor" do
      plan = build_plan(false, true, false)
      expect(plan.shared?).to eql(true)
    end

    it "is shared if the plan has an commenter" do
      plan = build_plan(false, false, true)
      expect(plan.shared?).to eql(true)
    end

  end

  describe "#owner_and_coowners" do

    let!(:plan) { build_plan(true, true, true) }

    subject { plan }

    it "includes the creator" do
      user = subject.roles.creator.first.user
      expect(subject.owner_and_coowners).to include(user)
    end

    it "includes the administrator" do
      user = subject.roles.administrator.first.user
      expect(subject.owner_and_coowners).to include(user)
    end

    it "does not include the editor" do
      # Only if the editor is not also an administrator or creator
      subject.roles.editor.each do |role|
        if !role.creator? && !role.administrator?
          expect(subject.owner_and_coowners).to_not include(role.user)
        end
      end
    end

    it "does not include the commenter" do
      # Only if the commenter is not also an administrator or creator
      subject.roles.commenter.each do |role|
        if !role.creator? && !role.administrator?
          expect(subject.owner_and_coowners).to_not include(role.user)
        end
      end
    end

  end

  describe ".authors" do
    let!(:plan) { build_plan(true, true, true) }

    subject { plan }

    it "includes the creator" do
      user = subject.roles.creator.first.user
      expect(subject.authors).to include(user)
    end

    it "includes the administrator" do
      user = subject.roles.administrator.first.user
      expect(subject.authors).to include(user)
    end

    it "includes the editor" do
      user = subject.roles.editor.first.user
      expect(subject.authors).to include(user)
    end

    it "does not include the commenter" do
      # Only if the commenter is not also an editor, administrator or creator
      subject.roles.commenter.each do |role|
        if !role.creator? && !role.administrator? && !role.editor?
          expect(subject.authors).to_not include(role.user)
        end
      end
    end
  end

  describe "#num_answered_questions" do

    let!(:template) { create(:template) }

    let!(:plan) { create(:plan, :creator, template: template) }

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

    let!(:plan) { create(:plan, :creator, template: template) }

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

    let!(:plan) { create(:plan, :creator, template: template) }

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

    context "when Question with ID and Plan exists" do

      let!(:question) { create(:question) }

      let!(:plan) { create(:plan, :creator, template: question.section.phase.template) }

      subject { plan.question_exists?(question.id) }

      it { is_expected.to eql(true) }

    end

    context "when Question with ID and Plan don't exist" do

      let!(:question) { create(:question) }

      let!(:plan) { create(:plan, :creator) }

      subject { plan.question_exists?(question.id) }

      it { is_expected.to eql(false) }

    end

  end

  describe "#no_questions_matches_no_answers?" do

    let!(:plan) { create(:plan, :creator) }

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

  describe "#landing_page" do
    let!(:plan) { create(:plan, :creator) }

    it "returns nil if no DOI or ARK is available" do
      expect(plan.landing_page).to eql(nil)
    end
    it "returns the DOI if available" do
      id = create(:identifier, identifiable: plan, value: "10.9999/123erge/45f")
      plan.reload
      expect(plan.landing_page).to eql(id)
    end
    it "returns the ARK if available" do
      id = create(:identifier, identifiable: plan, value: "ark:10.9999/123")
      plan.reload
      expect(plan.landing_page).to eql(id)
    end
  end

  describe "#doi" do
    before(:each) do
      @plan = create(:plan, :creator)
      IdentifierScheme.for_identification.destroy_all
    end

    it "returns nil if there are no IdentifierScheme :for_identification" do
      expect(@plan.doi).to eql(nil)
    end
    it "returns nil if the Plan has no DOI" do
      IdentifierScheme.create(for_identification: true, name: "foo", active: true)
      expect(@plan.doi).to eql(nil)
    end
    it "returns the correct identifier" do
      scheme = IdentifierScheme.create(for_identification: true, name: "foo",
                                       active: true)
      id = create(:identifier, identifier_scheme: scheme, identifiable: @plan)
      @plan.reload
      expect(@plan.doi).to eql(id)
    end
  end

  describe "#grant association sanity checks" do
    let!(:plan) { create(:plan, :creator) }

    it "allows a grant identifier to be associated" do
      plan.grant = build(:identifier, identifier_scheme: nil)
      plan.save
      expect(plan.grant.new_record?).to eql(false)
    end
    it "allows a grant identifier to be deleted" do
      plan.grant = build(:identifier, identifier_scheme: nil)
      plan.save
      plan.grant = nil
      plan.save
      expect(plan.grant).to eql(nil)
      expect(Identifier.last).to eql(nil)
    end
    it "does not allow multiple grants on a single plan" do
      plan.grant = build(:identifier, identifier_scheme: nil)
      plan.save
      val = SecureRandom.uuid
      plan.grant = build(:identifier, identifier_scheme: nil, value: val)
      plan.save
      expect(plan.grant.new_record?).to eql(false)
      expect(plan.grant.value).to eql(val)
      expect(Identifier.all.length).to eql(1)
    end
    it "allows the same grant to be associated with different plans" do
      val = SecureRandom.uuid
      id = build(:identifier, identifier_scheme: nil, value: val)
      plan.grant = id
      plan.save
      plan2 = create(:plan, grant: id)
      expect(plan2.grant).to eql(plan.grant)
      expect(plan2.grant.value).to eql(plan.grant.value)
      # Make sure that deleting the plan does not delete the shared grant!
      plan.destroy
      expect(plan2.grant).not_to eql(nil)
    end
  end

end
