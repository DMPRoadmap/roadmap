# frozen_string_literal: true

require 'rails_helper'

describe Plan do
  include Helpers::IdentifierHelper
  include Helpers::RolesHelper
  include Helpers::TemplateHelper

  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_presence_of(:template) }

    it { is_expected.to allow_values(true, false).for(:feedback_requested) }

    it { is_expected.not_to allow_value(nil).for(:feedback_requested) }

    it { is_expected.to allow_values(true, false).for(:complete) }

    it { is_expected.not_to allow_value(nil).for(:complete) }

    describe 'dates' do
      before do
        @plan = build(:plan)
      end

      it 'allows start_date to be nil' do
        @plan.start_date = nil
        @plan.end_date = 3.days.from_now
        expect(@plan.valid?).to be(true)
      end

      it 'allows end_date to be nil' do
        @plan.start_date = 3.days.from_now
        @plan.end_date = nil
        expect(@plan.valid?).to be(true)
      end

      it 'does not allow end_date to come before start_date' do
        @plan.start_date = 3.days.from_now
        @plan.end_date = Time.zone.now
        expect(@plan.valid?).to be(false)
      end
    end
  end

  context 'associations' do
    it { is_expected.to belong_to :template }

    it { is_expected.to belong_to :org }

    it { is_expected.to belong_to(:research_domain).optional }

    it { is_expected.to belong_to(:funder).optional }

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

    it { is_expected.to have_many(:subscriptions) }

    it { is_expected.to have_many(:related_identifiers) }
  end

  describe '.publicly_visible' do
    subject { described_class.publicly_visible }

    context 'when plan visibility is publicly_visible' do
      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.to include(plan) }
    end

    context 'when plan visibility is organisationally_visible' do
      let!(:plan) { create(:plan, :creator, :organisationally_visible) }

      it { is_expected.not_to include(plan) }
    end

    context 'when plan visibility is is_test' do
      let!(:plan) { create(:plan, :creator, :is_test) }

      it { is_expected.not_to include(plan) }
    end

    context 'when plan visibility is privately_visible' do
      let!(:plan) { create(:plan, :creator, :privately_visible) }

      it { is_expected.not_to include(plan) }
    end
  end

  describe '.organisationally_visible' do
    subject { described_class.organisationally_visible }

    context 'when plan visibility is publicly_visible' do
      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.not_to include(plan) }
    end

    context 'when plan visibility is organisationally_visible' do
      let!(:plan) { create(:plan, :creator, :organisationally_visible) }

      it { is_expected.to include(plan) }
    end

    context 'when plan visibility is is_test' do
      let!(:plan) { create(:plan, :creator, :is_test) }

      it { is_expected.not_to include(plan) }
    end

    context 'when plan visibility is privately_visible' do
      let!(:plan) { create(:plan, :creator, :privately_visible) }

      it { is_expected.not_to include(plan) }
    end
  end

  describe '.privately_visible' do
    subject { described_class.privately_visible }

    context 'when plan visibility is publicly_visible' do
      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.not_to include(plan) }
    end

    context 'when plan visibility is organisationally_visible' do
      let!(:plan) { create(:plan, :creator, :organisationally_visible) }

      it { is_expected.not_to include(plan) }
    end

    context 'when plan visibility is is_test' do
      let!(:plan) { create(:plan, :creator, :is_test) }

      it { is_expected.not_to include(plan) }
    end

    context 'when plan visibility is privately_visible' do
      let!(:plan) { create(:plan, :creator, :privately_visible) }

      it { is_expected.to include(plan) }
    end
  end

  describe '.organisationally_or_publicly_visible' do
    subject { described_class.organisationally_or_publicly_visible(user) }

    let!(:user) { create(:user) }

    context 'when user is creator' do
      before do
        create(:role, :creator, user: user, plan: plan)
      end

      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.not_to include(plan) }
    end

    context 'when user is administrator' do
      before do
        create(:role, :administrator, user: user, plan: plan)
      end

      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.not_to include(plan) }
    end

    context 'when user is commenter' do
      before do
        create(:role, :commenter, user: user, plan: plan)
      end

      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.not_to include(plan) }
    end

    context 'when user is editor' do
      before do
        create(:role, :editor, user: user, plan: plan)
      end

      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.not_to include(plan) }
    end

    context 'when plan visibility is publicly_visible' do
      before do
        new_user = create(:user, org: user.org)
        create(:role, :creator, :administrator, :editor, :commenter,
               user: new_user, plan: plan)
      end

      let!(:template) { build_template(1, 1, 1) }
      let!(:plan) { create(:plan, :creator, :organisationally_visible, template: template) }
      let!(:answer) do
        create(:answer, plan: plan,
                        question: template.phases.first.sections.first.questions.first)
      end

      it 'includes publicly_visible plans' do
        expect(subject).to include(plan)
      end
    end

    context 'when plan visibility is organisationally_visible' do
      before do
        new_user = create(:user, org: user.org)
        create(:role, :creator, :administrator, :editor, :commenter,
               user: new_user, plan: plan)
      end

      let!(:template) { build_template(1, 1, 1) }
      let!(:plan) { create(:plan, :creator, :organisationally_visible, template: template) }
      let!(:answer) do
        create(:answer, plan: plan,
                        question: template.phases.first.sections.first.questions.first)
      end

      it 'includes organisationally_visible plans' do
        expect(subject).to include(plan)
      end
    end

    context 'when plan is not complete' do
      before do
        new_user = create(:user, org: user.org)
        create(:role, :creator, :administrator, :editor, :commenter,
               user: new_user, plan: plan)
      end

      let!(:plan) { create(:plan, :creator, :organisationally_visible) }

      it 'includes organisationally_visible plans' do
        expect(subject).not_to include(plan)
      end
    end

    context 'when plan visibility is is_test' do
      let!(:plan) { create(:plan, :creator, :is_test) }

      it { is_expected.not_to include(plan) }
    end

    context 'when plan visibility is privately_visible' do
      let!(:plan) { create(:plan, :creator, :privately_visible) }

      it { is_expected.not_to include(plan) }
    end

    context 'when plan has no active roles' do
      let!(:plan) { build_plan }

      it 'is not included' do
        plan.roles.inject(&:deactivate!)
        expect(subject).not_to include(plan)
      end
    end
  end

  describe '.is_test' do
    subject { described_class.is_test }

    context 'when plan visibility is publicly_visible' do
      let!(:plan) { create(:plan, :creator, :publicly_visible) }

      it { is_expected.not_to include(plan) }
    end

    context 'when plan visibility is organisationally_visible' do
      let!(:plan) { create(:plan, :creator, :organisationally_visible) }

      it { is_expected.not_to include(plan) }
    end

    context 'when plan visibility is is_test' do
      let!(:plan) { create(:plan, :creator, :is_test) }

      it { is_expected.to include(plan) }
    end

    context 'when plan visibility is privately_visible' do
      let!(:plan) { create(:plan, :creator, :privately_visible) }

      it { is_expected.not_to include(plan) }
    end
  end

  describe '.active' do
    subject { described_class.active(user) }

    let!(:plan) { create(:plan, :creator) }

    let!(:user) { create(:user) }

    context 'where user role is active' do
      before do
        create(:role, :active, :creator, user: user, plan: plan)
      end

      it { is_expected.to include(plan) }
    end

    context 'where user role is not active' do
      before do
        create(:role, :inactive, :creator, user: user, plan: plan)
      end

      it { is_expected.not_to include(plan) }
    end
  end

  describe '.load_for_phase' do
    subject { described_class.load_for_phase(plan.id, phase.id) }

    let!(:template) { create(:template) }

    let!(:plan) { create(:plan, :creator, template: template) }

    let!(:phase) { create(:phase, template: template) }

    let!(:section) { create(:section, phase: phase) }

    let!(:question) { create(:question, section: section) }

    context 'when Plan ID is valid and Phase ID is valid child' do
      it 'returns an Array' do
        expect(subject).to be_an(Array)
      end

      it 'returns the Plan first' do
        expect(subject.first).to eql(plan)
      end

      it 'returns the Phase second' do
        expect(subject.second).to eql(phase)
      end
    end

    context 'when Plan ID is valid and Phase ID is not valid child' do
      let!(:phase) { create(:phase) }

      it 'raises an exception' do
        # TODO: This is not ideal behaviour. Fix this.
        expect { subject }.to raise_error(NoMethodError)
      end
    end

    context 'when Plan ID is not valid' do
      let!(:plan) { stub(id: 0) }

      it 'raises an exception' do
        # TODO: This is not ideal behaviour. Fix this.
        expect { subject }.to raise_error(NoMethodError)
      end
    end
  end

  describe '.deep_copy' do
    subject { described_class.deep_copy(plan) }

    let!(:plan) do
      create(:plan, :creator, answers: 2, guidance_groups: 2,
                              feedback_requested: true)
    end

    it "prepends the title with 'Copy'" do
      expect(subject.title).to include('Copy')
    end

    it 'sets feedback_requested to false' do
      expect(subject.feedback_requested).to be(false)
    end

    it 'copies the title from source' do
      expect(subject.title).to include(plan.title)
    end

    it 'persists the record' do
      expect(subject).to be_persisted
    end

    it 'creates new copies of the answers' do
      expect(subject.answers).to have(2).items
    end

    it 'duplicates the guidance groups' do
      expect(subject.guidance_groups).to have(2).items
    end
  end

  describe '.search' do
    subject { described_class.search('foo') }

    context 'when Plan title matches term' do
      let!(:plan) { create(:plan, :creator, title: 'foolike title') }

      it { is_expected.to include(plan) }
    end

    context 'when Template title matches term' do
      let!(:template) { create(:template, title: 'foolike title') }

      let!(:plan) { create(:plan, :creator, template: template) }

      it { is_expected.to include(plan) }
    end

    context 'when Organisation name matches term' do
      let!(:plan)  { create(:plan, :creator, description: 'foolike desc') }

      let!(:org) { create(:org, name: 'foolike name') }

      before do
        user = plan.owner
        user.org = org
        user.save
      end

      it 'returns organisation name' do
        expect(subject).to include(plan)
      end
    end

    context 'when Contributor name matches term' do
      let!(:plan) { create(:plan, :creator, description: 'foolike desc') }
      let!(:contributor) { create(:contributor, plan: plan, name: 'Dr. Foo Bar') }

      it 'returns contributor name' do
        expect(subject).to include(plan)
      end
    end

    context 'when neither title matches term' do
      let!(:plan) { create(:plan, :creator, description: 'foolike desc') }

      it { is_expected.not_to include(plan) }
    end
  end

  describe '.stats_filter' do
    subject { described_class.all.stats_filter }

    context 'when plan visibility is test' do
      let!(:plan) { create(:plan, :creator, :is_test) }

      it { is_expected.not_to include(plan) }
    end

    context 'when plan visibility is not test' do
      let!(:p1)  { create(:plan, :creator, :publicly_visible) }
      let!(:p2)  { create(:plan, :creator, :privately_visible) }
      let!(:p3)  { create(:plan, :creator, :organisationally_visible) }

      it { is_expected.to include(p1) }
      it { is_expected.to include(p2) }
      it { is_expected.to include(p3) }
    end
  end

  describe '#answer' do
    subject { plan.answer(question.id, create_if_missing) }

    let!(:plan) { create(:plan, :creator, answers: 1) }

    let!(:question) { create(:question) }

    context 'when create_if_missing is true and answer exists on the DB' do
      let!(:create_if_missing) { true }

      let!(:answer) { create(:answer, plan: plan, question: question) }

      it 'returns the existing Answer' do
        expect(subject).to eql(answer)
      end
    end

    context "when create_if_missing is true and answer doesn't exist on the DB" do
      let!(:create_if_missing) { true }

      it 'returns a new Answer' do
        expect(subject).to be_an(Answer)
      end

      it "doesn't persist the new Answer" do
        expect(subject).to be_new_record
      end
    end

    context 'when create_if_missing is false and qid exists on the DB' do
      let!(:create_if_missing) { false }

      let!(:answer) { create(:answer, plan: plan, question: question) }

      it 'returns the existing Answer' do
        expect(subject).to eql(answer)
      end
    end

    context "when create_if_missing is false and qid doesn't exist on the DB" do
      let!(:create_if_missing) { false }

      let!(:answer) { nil }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#guidance_group_options' do
    subject { plan.guidance_group_options }

    let!(:plan) { create(:plan, :creator) }

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

    context 'when guidance groups are unpublished' do
      before do
        @guidance_group.update(published: false)
      end

      it 'excludes the guidance group from options' do
        expect(subject).not_to include(@guidance_group)
      end
    end

    context 'when guidance groups are published' do
      it 'includes the guidance group in options' do
        expect(subject).to include(@guidance_group)
      end
    end
  end

  describe '#request_feedback' do
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

    context 'when org contact_email present' do
      before do
        org.update!(contact_email: Faker::Internet.email)
      end

      it 'emails the admins' do
        expect { subject }.to change {
          ActionMailer::Base.deliveries.size
        }.by(1)
      end
    end
  end

  describe '#complete_feedback' do
    subject { plan.complete_feedback(user) }

    let!(:org)  { create(:org) }

    let!(:user) { create(:user, org: org) }

    let!(:admin) { create(:user) }

    let!(:template) { create(:template, phases: 2) }

    let!(:plan) do
      create(:plan, feedback_requested: true,
                    template: template)
    end

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
          .returns(users: { feedback_provided: false })
      expect { subject }.not_to change { ActionMailer::Base.deliveries.size }
    end

    context 'when user feedback provided pref is true' do
      before do
        User.any_instance.stubs(:get_preferences)
            .returns(users: { feedback_provided: true })
      end

      it 'emails the owners' do
        expect { subject }.to change {
          ActionMailer::Base.deliveries.size
        }.by(2)
      end
    end
  end

  describe '#editable_by?' do
    subject { plan }

    let!(:plan) { build_plan(true, true, true) }

    it 'when role is inactive' do
      role = subject.roles.editor.first
      role.deactivate!
      user = role.user
      expect(subject.editable_by?(user.id)).to be(false)
    end

    it 'when user is a creator' do
      # All creators should be able to edit
      subject.roles.creator.pluck(:user_id).each do |user_id|
        expect(subject.editable_by?(user_id)).to be(true)
      end
    end

    it 'when user is a administrator' do
      # All administrators (aka coowners) should be able to edit
      subject.roles.administrator.pluck(:user_id).each do |user_id|
        expect(subject.editable_by?(user_id)).to be(true)
      end
    end

    it 'when user is a editor' do
      # All editors should be able to edit
      subject.roles.editor.pluck(:user_id).each do |user_id|
        expect(subject.editable_by?(user_id)).to be(true)
      end
    end

    it 'when user is a commenter' do
      # Commenters should only be able to edit if they are also
      # a creator, administrator or editor
      subject.roles.commenter.each do |role|
        expect(subject.editable_by?(role.user.id)).to eql(role.editor?)
      end
    end
  end

  describe '#readable_by?' do
    subject { plan }

    let!(:user) { create(:user, org: create(:org)) }
    let!(:plan) { build_plan(true, true, true) }

    context 'config allows for admin viewing' do
      it 'super admins' do
        original_setting = Rails.configuration.x.plans.super_admins_read_all
        Rails.configuration.x.plans.super_admins_read_all = true
        user.perms << create(:perm, name: 'add_organisations')
        expect(subject.readable_by?(user.id)).to be(true)
        Rails.configuration.x.plans.super_admins_read_all = original_setting
      end

      it 'org admins' do
        original_setting = Rails.configuration.x.plans.super_admins_read_all
        Rails.configuration.x.plans.org_admins_read_all = true
        user.org_id = plan.owner.org_id
        user.save
        user.perms << create(:perm, name: 'modify_guidance')
        expect(subject.readable_by?(user.id)).to be(true)
        Rails.configuration.x.plans.super_admins_read_all = original_setting
      end
    end

    context 'config does not allow admin viewing' do
      before do
        @org_admins = Rails.configuration.x.plans.org_admins_read_all
        @super_admins = Rails.configuration.x.plans.super_admins_read_all
        Rails.configuration.x.plans.org_admins_read_all = false
        Rails.configuration.x.plans.super_admins_read_all = false
      end

      after do
        Rails.configuration.x.plans.org_admins_read_all = @org_admins
        Rails.configuration.x.plans.super_admins_read_all = @super_admins
      end

      it 'super admins' do
        user.perms << create(:perm, name: 'add_organisations')
        expect(subject.readable_by?(user.id)).to be(false)
      end

      it 'org admins' do
        user.perms << create(:perm, name: 'modify_guidance')
        expect(subject.readable_by?(user.id)).to be(false)
      end
    end

    context 'non-admin user' do
      it 'when role is inactive' do
        role = subject.roles.commenter.first
        role.deactivate!
        user = role.user
        expect(subject.readable_by?(user.id)).to be(false)
      end

      it 'when user is a creator' do
        # All creators should be able to read
        subject.roles.creator.pluck(:user_id).each do |user_id|
          expect(subject.readable_by?(user_id)).to be(true)
        end
      end

      it 'when user is a administrator' do
        # All administrators should be able to read
        subject.roles.administrator.pluck(:user_id).each do |user_id|
          expect(subject.readable_by?(user_id)).to be(true)
        end
      end

      it 'when user is a editor' do
        # All editors should be able to read
        subject.roles.editor.pluck(:user_id).each do |user_id|
          expect(subject.readable_by?(user_id)).to be(true)
        end
      end

      it 'when user is a commenter' do
        # All commenters should be able to read
        subject.roles.commenter.pluck(:user_id).each do |user_id|
          expect(subject.readable_by?(user_id)).to be(true)
        end
      end

      context 'When user is a reviewer' do
        before do
          user.org = plan.owner.org
          user.save
          user.perms << create(:perm, :review_org_plans)
        end

        it 'when user is a reviewer and feedback requested' do
          # All reviewers of the same org should be able to comment
          plan.feedback_requested = true
          plan.save
          expect(subject.readable_by?(user.id)).to be(true)
        end

        it 'when user is a reviewer and feedback not requested' do
          original_setting = Rails.configuration.x.plans.super_admins_read_all
          Rails.configuration.x.plans.org_admins_read_all = false
          plan.feedback_requested = false
          plan.save
          expect(subject.readable_by?(user.id)).to be(false)
          Rails.configuration.x.plans.super_admins_read_all = original_setting
        end

        it 'when user is a reviewer of a different org and feedback requested' do
          # reviewers of other orgs should have no access
          user.org = create(:org)
          user.save
          user.perms << create(:perm, :review_org_plans)
          plan.feedback_requested = true
          plan.save
          expect(subject.readable_by?(user.id)).to be(false)
        end
      end

      it 'when user is not reviewer, has no roles on the plan and feedback requested' do
        # All reviewers should be able to comment
        user.org = plan.owner.org
        user.save
        plan.feedback_requested = true
        plan.save
        expect(subject.readable_by?(user.id)).to be(false)
      end
    end

    context 'explicit sharing does not conflict with admin-viewing' do
      it 'super admins' do
        original_setting = Rails.configuration.x.plans.super_admins_read_all
        Rails.configuration.x.plans.super_admins_read_all = false
        user.perms << create(:perm, name: 'add_organisations')
        role = subject.roles.commenter.first
        role.user_id = user.id
        role.save!

        expect(subject.readable_by?(user.id)).to be(true)
        Rails.configuration.x.plans.super_admins_read_all = original_setting
      end

      it 'org admins' do
        original_setting = Rails.configuration.x.plans.super_admins_read_all
        Rails.configuration.x.plans.org_admins_read_all = false
        user.perms << create(:perm, name: 'modify_guidance')
        role = subject.roles.commenter.first
        role.user_id = user.id
        role.save!

        expect(subject.readable_by?(user.id)).to be(true)
        Rails.configuration.x.plans.super_admins_read_all = original_setting
      end
    end
  end

  describe '#commentable_by?' do
    subject { plan }

    let!(:plan) { build_plan(true, true, true) }
    let(:user) { create(:user) }

    let(:user) { create(:user) }

    it 'when role is inactive' do
      role = subject.roles.commenter.first
      role.deactivate!
      user = role.user
      expect(subject.commentable_by?(user.id)).to be(false)
    end

    it 'when user is a creator' do
      # All creators should be able to comment
      subject.roles.creator.pluck(:user_id).each do |user_id|
        expect(subject.commentable_by?(user_id)).to be(true)
      end
    end

    it 'when user is a administrator' do
      # All administrators should be able to comment
      subject.roles.administrator.pluck(:user_id).each do |user_id|
        expect(subject.commentable_by?(user_id)).to be(true)
      end
    end

    it 'when user is a editor' do
      # All editors should be able to comment
      subject.roles.editor.pluck(:user_id).each do |user_id|
        expect(subject.commentable_by?(user_id)).to be(true)
      end
    end

    it 'when user is a commenter' do
      # All commenters should be able to comment
      subject.roles.commenter.pluck(:user_id).each do |user_id|
        expect(subject.commentable_by?(user_id)).to be(true)
      end
    end

    context 'when user is a reviewer' do
      before do
        user.org = plan.owner.org
        user.save
        user.perms << create(:perm, :review_org_plans)
      end

      it 'of the same org and feedback requested' do
        # All reviewers of the same org should be able to comment
        plan.feedback_requested = true
        plan.save
        expect(subject.commentable_by?(user.id)).to be(true)
      end

      it 'of the same org and feedback not requested' do
        plan.feedback_requested = false
        plan.save
        expect(subject.commentable_by?(user.id)).to be(false)
      end

      it 'of a different org and feedback requested' do
        # All reviewers of other orgs should not be able to comment
        user.org = create(:org)
        user.save
        # re-add permissions as org-admins will have these removed on save
        user.perms << create(:perm, :review_org_plans)
        plan.feedback_requested = true
        plan.save
        expect(subject.commentable_by?(user.id)).to be(false)
      end
    end

    it 'when user is not reviewer, has no roles on the plan and feedback requested' do
      # All reviewers should be able to comment
      user.org = plan.owner.org
      user.save
      plan.feedback_requested = true
      plan.save
      expect(subject.commentable_by?(user.id)).to be(false)
    end
  end

  describe '#administerable_by?' do
    subject { plan }

    let!(:plan) { build_plan(true, true, true) }

    it 'when role is inactive' do
      role = subject.roles.administrator.first
      role.deactivate!
      user = role.user
      expect(subject.administerable_by?(user.id)).to be(false)
    end

    it 'when user is a creator' do
      # All creators should be able to administer
      subject.roles.creator.pluck(:user_id).each do |user_id|
        expect(subject.administerable_by?(user_id)).to be(true)
      end
    end

    it 'when user is a administrator' do
      # All administrators should be able to administer
      subject.roles.administrator.pluck(:user_id).each do |user_id|
        expect(subject.administerable_by?(user_id)).to be(true)
      end
    end

    it 'when user is a editor' do
      # Editors should only be able to administer if they are also
      # a creator or administrator
      subject.roles.editor.each do |role|
        expect(subject.administerable_by?(role.user.id)).to eql(role.administrator?)
      end
    end

    it 'when user is a commenter' do
      # Commenters should only be able to administer if they are also
      # a creator or administrator
      subject.roles.commenter.each do |role|
        expect(subject.administerable_by?(role.user.id)).to eql(role.administrator?)
      end
    end
  end

  describe '#reviewable_by?' do
    subject { plan }

    let!(:plan) { build_plan(true, true, true) }
    let!(:user) { create(:user) }

    before do
      plan.feedback_requested = true
      plan.save
      create(:perm, :review_org_plans)
    end

    it 'when user is not a reviewer' do
      expect(subject.reviewable_by?(user.id)).to be(false)
    end

    it 'when user is a reviewer' do
      user.org = plan.owner.org
      user.save
      user.perms << Perm.review_plans
      expect(subject.owner.org).to eql(user.org)
      expect(user.can_review_plans?).to be(true)
      expect(plan.feedback_requested?).to be(true)
      expect(subject.reviewable_by?(user.id)).to be(true)
    end
  end

  describe '#latest_update' do
    subject { plan.latest_update.to_i }

    let!(:plan) { create(:plan, :creator, updated_at: 5.minutes.ago) }

    context 'when plan updated_at is latest' do
      before do
        create_list(:phase, 2, template: plan.template,
                               updated_at: 6.minutes.ago)
      end

      it "returns the plan's updated_at value" do
        expect(subject).to eql(plan.updated_at.to_i)
      end
    end

    context 'when plan has phases updated_at latest' do
      before do
        create_list(:phase, 2, template: plan.template)
      end

      it "returns the plan's updated_at value" do
        expect(subject).to be_within(5.seconds).of(Time.current.to_i)
      end
    end
  end

  describe '#name' do
    let!(:plan) { build(:plan, :creator, title: 'Foo bar') }

    it 'returns the title' do
      expect(plan.name).to eql('Foo bar')
    end
  end

  describe '#owner' do
    subject { plan }

    let!(:plan) { build_plan(true, true, true) }

    it 'is the creator' do
      user = subject.roles.creator.first.user
      expect(subject.owner).to eql(user)
    end

    it 'is the administrator if there is no creator' do
      subject.roles.creator.first.deactivate!
      user = subject.roles.where(active: true).administrator.first.user
      expect(subject.owner).to eql(user)
    end
  end

  describe '#add_user' do
    subject { plan }

    let!(:user) { create(:user, org: create(:org)) }
    let!(:plan) { build_plan }

    it 'returns false if user does not exist' do
      expect(subject.add_user!(326_465)).to be(false)
    end

    it 'adds the creator' do
      expect(subject.add_user!(user.id, :creator)).to be(true)
      role = Role.find_by(user_id: user.id, plan_id: subject.id)
      expect(role.creator?).to be(true)
      expect(role.administrator?).to be(true)
      expect(role.editor?).to be(true)
      expect(role.commenter?).to be(true)
      expect(role.reviewer?).to be(false)
    end

    it 'adds the administrator' do
      expect(subject.add_user!(user.id, :administrator)).to be(true)
      role = Role.find_by(user_id: user.id, plan_id: subject.id)
      expect(role.creator?).to be(false)
      expect(role.administrator?).to be(true)
      expect(role.editor?).to be(true)
      expect(role.commenter?).to be(true)
      expect(role.reviewer?).to be(false)
    end

    it 'adds the editor' do
      expect(subject.add_user!(user.id, :editor)).to be(true)
      role = Role.find_by(user_id: user.id, plan_id: subject.id)
      expect(role.creator?).to be(false)
      expect(role.administrator?).to be(false)
      expect(role.editor?).to be(true)
      expect(role.commenter?).to be(true)
      expect(role.reviewer?).to be(false)
    end

    it 'adds the commenter' do
      expect(subject.add_user!(user.id, :commenter)).to be(true)
      role = Role.find_by(user_id: user.id, plan_id: subject.id)
      expect(role.creator?).to be(false)
      expect(role.administrator?).to be(false)
      expect(role.editor?).to be(false)
      expect(role.commenter?).to be(true)
      expect(role.reviewer?).to be(false)
    end

    it 'defaults to commenter if access_level is not a known symbol' do
      expect(subject.add_user!(user.id)).to be(true)
      role = Role.find_by(user_id: user.id, plan_id: subject.id)
      expect(role.creator?).to be(false)
      expect(role.administrator?).to be(false)
      expect(role.editor?).to be(false)
      expect(role.commenter?).to be(true)
      expect(role.reviewer?).to be(false)
    end
  end

  describe '#shared?' do
    it 'is not shared if the only user is the creator' do
      plan = build_plan
      expect(plan.shared?).to be(false)
    end

    it 'is shared if the plan has an administrator' do
      plan = build_plan(true, false, false)
      expect(plan.shared?).to be(true)
    end

    it 'is shared if the plan has an editor' do
      plan = build_plan(false, true, false)
      expect(plan.shared?).to be(true)
    end

    it 'is shared if the plan has an commenter' do
      plan = build_plan(false, false, true)
      expect(plan.shared?).to be(true)
    end
  end

  describe '#owner_and_coowners' do
    subject { plan }

    let!(:plan) { build_plan(true, true, true) }

    it 'includes the creator' do
      user = subject.roles.creator.first.user
      expect(subject.owner_and_coowners).to include(user)
    end

    it 'includes the administrator' do
      user = subject.roles.administrator.first.user
      expect(subject.owner_and_coowners).to include(user)
    end

    it 'does not include the editor' do
      # Only if the editor is not also an administrator or creator
      subject.roles.editor.each do |role|
        expect(subject.owner_and_coowners).not_to include(role.user) if !role.creator? && !role.administrator?
      end
    end

    it 'does not include the commenter' do
      # Only if the commenter is not also an administrator or creator
      subject.roles.commenter.each do |role|
        expect(subject.owner_and_coowners).not_to include(role.user) if !role.creator? && !role.administrator?
      end
    end
  end

  describe '.authors' do
    subject { plan }

    let!(:plan) { build_plan(true, true, true) }

    it 'includes the creator' do
      user = subject.roles.creator.first.user
      expect(subject.authors).to include(user)
    end

    it 'includes the administrator' do
      user = subject.roles.administrator.first.user
      expect(subject.authors).to include(user)
    end

    it 'includes the editor' do
      user = subject.roles.editor.first.user
      expect(subject.authors).to include(user)
    end

    it 'does not include the commenter' do
      # Only if the commenter is not also an editor, administrator or creator
      subject.roles.commenter.each do |role|
        expect(subject.authors).not_to include(role.user) if !role.creator? && !role.administrator? && !role.editor?
      end
    end
  end

  describe '#percent_answered' do
    subject { plan.percent_answered }

    let!(:template) { create(:template) }

    let!(:plan) { create(:plan, :creator, template: template) }

    before do
      @phase     = create(:phase, template: template)
      @section   = create(:section, phase: @phase)
      @questions = create_list(:question, 3, :textarea, section: @section)
      # 1 valid answers
      @questions.first(1).each do |question|
        create(:answer, question: question, plan: plan)
      end
      # 1 valid answers
      @questions.last(1).each do |question|
        create(:answer, question: question, plan: plan, text: nil)
      end
    end

    it 'returns the percentage of questions with valid answers' do
      expect(subject.to_i).to be(33)
    end
  end

  describe '#num_questions' do
    subject { plan.num_questions }

    let!(:template) { create(:template) }

    let!(:plan) { create(:plan, :creator, template: template) }

    before do
      create_list(:phase, 2, template: template) do |phase|
        create_list(:section, 2, phase: phase) do |section|
          create_list(:question, 3, section: section)
        end
      end
    end

    it "returns the number of questions belonging to this plan's sections" do
      expect(subject).to be(12)
    end
  end

  describe '#visibility_allowed?' do
    subject { plan.visibility_allowed? }

    let!(:template) { create(:template) }

    let!(:plan) { create(:plan, :creator, template: template) }

    before do
      @phase     = create(:phase, template: template)
      @section   = create(:section, phase: @phase)
      @questions = create_list(:question, 4, :textarea, section: @section)
      @questions.take(3).each do |question|
        create(:answer, question: question, plan: plan)
      end
    end

    context 'when requisite number of questions answered' do
      before do
        @original_percentage = Rails.configuration.x.plans.default_percentage_answered
        Rails.configuration.x.plans.default_percentage_answered = 75
      end

      after do
        Rails.configuration.x.plans.default_percentage_answered = @original_percentage
      end

      it { is_expected.to be(true) }
    end

    context 'when requisite number of questions not answered' do
      before do
        @original_percentage = Rails.configuration.x.plans.default_percentage_answered
        Rails.configuration.x.plans.default_percentage_answered = 76
      end

      after do
        Rails.configuration.x.plans.default_percentage_answered = @original_percentage
      end

      it { is_expected.to be(false) }
    end
  end

  describe '#question_exists?' do
    context 'when Question with ID and Plan exists' do
      subject { plan.question_exists?(question.id) }

      let!(:question) { create(:question) }

      let!(:plan) { create(:plan, :creator, template: question.section.phase.template) }

      it { is_expected.to be(true) }
    end

    context "when Question with ID and Plan don't exist" do
      subject { plan.question_exists?(question.id) }

      let!(:question) { create(:question) }

      let!(:plan) { create(:plan, :creator) }

      it { is_expected.to be(false) }
    end
  end

  describe '#percent_answered' do
    subject { plan.percent_answered }

    let!(:template) { create(:template, phases: 1, sections: 1, questions: 1) }

    let!(:plan) { create(:plan, :creator, template: template) }

    context 'when has no answers' do
      it { is_expected.to be(0) }
    end

    context 'when has answers that are not valid' do
      let!(:question) do
        create(:question, :textarea, section: template.phases.first.sections.first)
      end

      before do
        create_list(:answer, 1, text: '', plan: plan, question: question)
      end

      it { is_expected.to be(0) }
    end

    context 'when has answers that are valid' do
      let!(:question) do
        create(:question, :textarea, section: template.phases.first.sections.first)
      end

      before do
        create_list(:answer, 1, plan: plan, question: question, text: Faker::Lorem.paragraph)
      end

      it { is_expected.to be(50.0) }
    end
  end

  describe '#registration_allowed?' do
    before do
      @original_reg = Rails.configuration.x.madmp.enable_dmp_id_registration
      @original_orcid = Rails.configuration.x.madmp.enable_orcid_publication
      Rails.configuration.x.madmp.enable_dmp_id_registration = true
      @plan = create(:plan, :creator, funder: create(:org))
      create(:identifier, identifier_scheme: create(:identifier_scheme, name: 'orcid'),
                          identifiable: @plan.owner)
      @plan.reload
    end

    after do
      Rails.configuration.x.madmp.enable_dmp_id_registration = @original_reg
      Rails.configuration.x.madmp.enable_orcid_publication = @original_orcid
    end

    it 'returns false if the config does not allow DMP ID registration' do
      Rails.configuration.x.madmp.enable_dmp_id_registration = false
      expect(@plan.registration_allowed?).to be(false)
    end

    it 'returns true if the creator/owner does not have an ORCID (but ORCID is disabled)' do
      Rails.configuration.x.madmp.enable_orcid_publication = false
      @plan.owner.identifiers.clear
      @plan.expects(:visibility_allowed?).returns(true)
      expect(@plan.registration_allowed?).to be(true)
    end

    it 'returns false if the creator/owner does not have an ORCID (and ORCID is enabled)' do
      Rails.configuration.x.madmp.enable_orcid_publication = true
      @plan.owner.identifiers.clear
      @plan.expects(:visibility_allowed?).returns(true)
      expect(@plan.registration_allowed?).to be(false)
    end

    it 'returns false if no Funder is defined' do
      @plan.funder = nil
      @plan.expects(:visibility_allowed?).returns(true)
      expect(@plan.registration_allowed?).to be(false)
    end

    it 'returns false if changing the visibility is not allowed' do
      @plan.expects(:visibility_allowed?).returns(false)
      expect(@plan.registration_allowed?).to be(false)
    end

    it 'returns true' do
      @plan.expects(:visibility_allowed?).returns(true)
      expect(@plan.registration_allowed?).to be(true)
    end
  end

  describe '#dmp_id' do
    before do
      @original_reg = Rails.configuration.x.madmp.enable_dmp_id_registration
      @plan = create(:plan, :creator)
      IdentifierScheme.for_plans.destroy_all
      @scheme = create(:identifier_scheme, name: 'foo', active: true, for_plans: true)
    end

    after do
      Rails.configuration.x.madmp.enable_dmp_id_registration = @original_reg
    end

    it 'returns nil if the config does not allow DMP ID registration' do
      Rails.configuration.x.madmp.enable_dmp_id_registration = false
      expect(@plan.dmp_id).to be_nil
    end

    it 'returns nil if the Plan has no DMP ID' do
      Rails.configuration.x.madmp.enable_dmp_id_registration = true
      expect(@plan.dmp_id).to be_nil
    end

    it 'returns the correct identifier' do
      Rails.configuration.x.madmp.enable_dmp_id_registration = true
      DmpIdService.expects(:identifier_scheme).returns(@scheme)
      id = create(:identifier, identifier_scheme: @scheme, identifiable: @plan)
      @plan.reload
      expect(@plan.dmp_id).to eql(id)
    end
  end

  describe '#citation' do
    before do
      @plan = create(:plan, :creator)
      @co_author = create(:user)
      create(:role, :administrator, user: @co_author, plan: @plan)
      @plan.reload
    end

    it 'returns nil if the plan has no owner' do
      @plan.roles.clear
      expect(@plan.citation).to be_nil
    end

    it 'returns nil if the plan has no DMP ID (aka doi)' do
      expect(@plan.citation).to be_nil
    end

    it 'returns the citation' do
      dmp_id = create_dmp_id(plan: @plan, val: SecureRandom.uuid)
      @plan.expects(:dmp_id).returns(dmp_id).twice
      result = @plan.citation
      auth = @plan.owner.name(false)
      expected = "#{auth}. (#{@plan.created_at.year}). \"#{@plan.title}\" [Data Management Plan]."
      expected += " #{ApplicationService.application_name}. #{dmp_id.value}"
      expect(result).to eql(expected)
    end
  end

  context 'private methods' do
    describe '#versionable_change?' do
      before do
        @plan = create(:plan, :is_test, complete: false).reload
      end

      it 'returns true if the :title changed' do
        @plan.update(title: SecureRandom.uuid)
        expect(@plan.send(:versionable_change?)).to be(true)
      end

      it 'returns true if the :description changed' do
        @plan.update(description: SecureRandom.uuid)
        expect(@plan.send(:versionable_change?)).to be(true)
      end

      it 'returns true if the :identifier changed' do
        @plan.update(identifier: SecureRandom.uuid)
        expect(@plan.send(:versionable_change?)).to be(true)
      end

      it 'returns true if the :visibility changed' do
        @plan.update(visibility: 0)
        expect(@plan.send(:versionable_change?)).to be(true)
      end

      it 'returns true if the :complete changed' do
        @plan.update(complete: true)
        expect(@plan.send(:versionable_change?)).to be(true)
      end

      it 'returns true if the :template_id changed' do
        @plan.update(template_id: create(:template).id)
        expect(@plan.send(:versionable_change?)).to be(true)
      end

      it 'returns true if the :org_id changed' do
        @plan.update(org_id: create(:org).id)
        expect(@plan.send(:versionable_change?)).to be(true)
      end

      it 'returns true if the :funder_id changed' do
        @plan.update(funder_id: create(:org).id)
        expect(@plan.send(:versionable_change?)).to be(true)
      end

      it 'returns true if the :grant_id changed' do
        @plan.update(grant_id: create(:identifier).id)
        expect(@plan.send(:versionable_change?)).to be(true)
      end

      it 'returns true if the :start_date changed' do
        @plan.update(start_date: 1.hour.from_now)
        expect(@plan.send(:versionable_change?)).to be(true)
      end

      it 'returns true if the :end_date changed' do
        @plan.update(end_date: 2.days.from_now)
        expect(@plan.send(:versionable_change?)).to be(true)
      end

      it 'returns false' do
        expect(@plan.send(:versionable_change?)).to be(false)
      end
    end

    describe ':notify_subscribers!' do
      before do
        @plan = create(:plan)
        @subscription = create(:subscription, subscriber: create(:api_client), plan: @plan,
                                              updates: true)
        @plan.reload
      end

      it 'returns true if there are no subscriptions' do
        @plan.subscriptions.clear
        expect(@plan.send(:notify_subscribers!)).to be(true)
      end

      it 'calls notify! for the subscription when no subscription_type is specified' do
        Subscription.any_instance.expects(:notify!).returns(true)
        expect(@plan.send(:notify_subscribers!)).to be(true)
      end

      it "calls notify! for the subscription when subscription_type is 'updates'" do
        Subscription.any_instance.expects(:notify!).returns(true)
        expect(@plan.send(:notify_subscribers!, subscription_types: [:updates])).to be(true)
      end

      it "does not call notify! for the subscription when subscription_type not 'updates'" do
        Subscription.any_instance.expects(:notify!).never
        expect(@plan.send(:notify_subscribers!, subscription_types: [:deletions])).to be(true)
      end
    end

    describe '#end_date_after_start_date' do
      before do
        @plan = build(:plan, start_date: Time.zone.now, end_date: 1.day.from_now)
      end

      it 'returns false and sets an error message when :end_date < :start_date' do
        @plan.end_date = @plan.start_date - 1.day
        expect(@plan.send(:end_date_after_start_date)).to be(false)
        expect(@plan.errors.full_messages).to eql(['End date must be after the start date'])
      end

      it 'returns true if :start_date is nil' do
        @plan.start_date = nil
        expect(@plan.send(:end_date_after_start_date)).to be(true)
      end

      it 'returns true if :end_date is nil' do
        @plan.end_date = nil
        expect(@plan.send(:end_date_after_start_date)).to be(true)
      end

      it 'returns true if :start_date is before :end_date' do
        @plan.end_date = @plan.start_date + 1.day
        expect(@plan.send(:end_date_after_start_date)).to be(true)
      end
    end
  end

  describe '#grant association sanity checks' do
    let!(:plan) { create(:plan, :creator) }

    it 'allows a grant identifier to be associated' do
      plan.grant = { value: build(:identifier, identifier_scheme: nil).value }
      plan.save
      expect(plan.grant.new_record?).to be(false)
    end

    it 'allows a grant identifier to be deleted' do
      plan.grant = { value: build(:identifier, identifier_scheme: nil).value }
      plan.save
      plan.grant = { value: nil }
      plan.save
      expect(plan.grant).to be_nil
      expect(Identifier.last).to be_nil
    end

    it 'does not allow multiple grants on a single plan' do
      plan.grant = { value: build(:identifier, identifier_scheme: nil).value }
      plan.save
      val = SecureRandom.uuid
      plan.grant = { value: build(:identifier, identifier_scheme: nil, value: val).value }
      plan.save
      expect(plan.grant.new_record?).to be(false)
      expect(plan.grant.value).to eql(val)
      expect(Identifier.all.length).to be(1)
    end
  end

  describe '#related_identifiers_attributes=(params)' do
    before do
      @plan = create(:plan, :creator)
      @related = create(:related_identifier, identifiable: @plan)
      @plan.reload
    end

    it 'removes existing related identifiers that are not part of :params' do
      old_id = @related.id

      val = SecureRandom.uuid
      params = {
        "#{Faker::Number.number(digits: 10)}": {
          work_type: RelatedIdentifier.work_types.keys.sample,
          value: val
        }
      }
      @plan.related_identifiers_attributes = JSON.parse(params.to_json)
      @plan.save
      @plan.reload
      expect(@plan.related_identifiers.length).to be(1)
      expect(@plan.related_identifiers.first.id).not_to eql(old_id)
      expect(@plan.related_identifiers.first.value).to eql(val)
    end

    it 'skips the hidden entry used by JS as a template for new related identifiers' do
      params = {
        "#{@related.id}": {
          work_type: @related.work_type,
          value: @related.value
        },
        '0': {
          work_type: RelatedIdentifier.work_types.keys.sample,
          value: SecureRandom.uuid
        }
      }
      @plan.related_identifiers_attributes = JSON.parse(params.to_json)
      @plan.save
      @plan.reload
      expect(@plan.related_identifiers.length).to be(1)
      expect(@plan.related_identifiers.first).to eql(@related)
    end

    it 'updates the existing related identifier' do
      work_type = RelatedIdentifier.work_types
                                   .reject { |wt| wt == @related.work_type }
                                   .keys.sample
      val = SecureRandom.uuid
      params = {
        "#{@related.id}": {
          work_type: work_type,
          value: val
        }
      }
      @plan.related_identifiers_attributes = JSON.parse(params.to_json)
      @plan.save
      @plan.reload
      expect(@plan.related_identifiers.length).to be(1)
      expect(@plan.related_identifiers.first.id).to eql(@related.id)
      expect(@plan.related_identifiers.first.work_type).to eql(work_type)
      expect(@plan.related_identifiers.first.value).to eql(val)
    end

    it 'adds a new related identifier' do
      work_type = RelatedIdentifier.work_types
                                   .reject { |wt| wt == @related.work_type }
                                   .keys.sample
      val = SecureRandom.uuid
      params = {
        "#{@related.id}": {
          work_type: @related.work_type,
          value: @related.value
        },
        "#{Faker::Number.number(digits: 10)}": {
          work_type: work_type,
          value: val
        }
      }
      @plan.related_identifiers_attributes = JSON.parse(params.to_json)
      @plan.save
      @plan.reload
      results = @plan.related_identifiers.order(:id)
      expect(results.length).to be(2)
      expect(results.first.id).to eql(@related.id)
      expect(results.first.work_type).to eql(@related.work_type)
      expect(results.first.value).to eql(@related.value)
      expect(results.last.work_type).to eql(work_type)
      expect(results.last.value).to eql(val)
    end
  end
end
