# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Org, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it {
      subject.name = 'DMP Company'
      is_expected.to validate_uniqueness_of(:name).case_insensitive
                                                  .with_message('must be unique')
    }

    it { is_expected.to allow_values(true, false).for(:is_other) }

    it { is_expected.not_to allow_value(nil).for(:is_other) }

    it { is_expected.to allow_values(0, 1).for(:managed) }

    it 'validates presence of contact_email if feedback_enabled' do
      subject.feedback_enabled = true
      is_expected.to validate_presence_of(:contact_email)
    end

    it "doesn't validate presence of contact_email if feedback_enabled nil" do
      subject.feedback_enabled = false
      is_expected.not_to validate_presence_of(:contact_email)
    end

    # validates :contact_email, presence: { message: PRESENCE_MESSAGE,
    #                                       if: :feedback_enabled }
    #
    # validates :org_type, presence: { message: PRESENCE_MESSAGE }
    #
    # validates :feedback_enabled, inclusion: { in: BOOLEAN_VALUES,
    #                                           message: INCLUSION_MESSAGE }
    #
  end

  context 'associations' do
    it { should belong_to(:language) }

    it { should belong_to(:region).optional }

    it { should have_many(:guidance_groups).dependent(:destroy) }

    it { should have_many(:templates) }

    it { should have_many(:users) }

    it { should have_many(:annotations) }

    it { should have_and_belong_to_many(:token_permission_types).join_table('org_token_permissions') }
    it { should have_many(:identifiers) }

    it { should have_many(:plans) }

    it { should have_many(:funded_plans) }
  end

  context 'scopes' do
    before(:each) do
      @managed = create(:org, managed: true)
      @unmanaged = create(:org, managed: false)
    end

    describe '.default_orgs' do
      subject { Org.default_orgs }

      context 'when Org has same abbr as dmproadmap.rb initializer setting' do
        let!(:org) do
          abbrev = Rails.configuration.x.organisation.abbreviation
          create(:org, abbreviation: abbrev)
        end

        it { is_expected.to include(org) }
      end

      context "when Org doesn't have same abbr as dmproadmap.rb initializer setting" do
        let!(:org) { create(:org, abbreviation: 'foo-bar') }

        it { is_expected.not_to include(org) }
      end
    end

    describe '#managed' do
      it 'returns only the managed orgs' do
        rslts = described_class.managed
        expect(rslts.include?(@managed)).to eql(true)
        expect(rslts.include?(@unmanaged)).to eql(false)
      end
    end
    describe '#unmanaged' do
      it 'returns only the un-managed orgs' do
        rslts = described_class.unmanaged
        expect(rslts.include?(@managed)).to eql(false)
        expect(rslts.include?(@unmanaged)).to eql(true)
      end
    end
  end

  describe '#locale' do
    let!(:org) { build(:org) }

    subject { org.locale }

    context 'language present' do
      it { is_expected.to be_present }
    end
  end

  describe '#org_type_to_s' do
    subject { org.org_type_to_s }

    context 'no organisation present' do
      let!(:org) { build(:org) }

      it { is_expected.to eql('None') }
    end

    context 'organisation present' do
      context 'when single organisation type and organisation type is Institution' do
        let!(:org) { build(:org, :institution) }

        it { is_expected.to eql('Institution') }
      end

      context 'when single organisation type and organisation type is Funder' do
        let!(:org) { build(:org, :funder) }

        it { is_expected.to eql('Funder') }
      end

      context 'when single organisation type and organisation type is Organisation' do
        let!(:org) { build(:org, :organisation) }

        it { is_expected.to eql('Organisation') }
      end

      context 'when single organisation type and organisation type is Research Institute' do
        let!(:org) { build(:org, :research_institute) }

        it { is_expected.to eql('Research Institute') }
      end

      context 'when single organisation type and organisation type is Project' do
        let!(:org) { build(:org, :project) }

        it { is_expected.to eql('Project') }
      end

      context 'when single organisation type and organisation type is School' do
        let!(:org) { build(:org, :school) }

        it { is_expected.to eql('School') }
      end

      context 'when organisation has multiple organisation types' do
        let!(:org) { build(:org, :funder, :school) }

        it { is_expected.to include('Funder', 'School') }
      end
    end
  end

  describe '#funder_only?' do
    let!(:org) { build(:org) }

    subject { org.funder_only? }

    context 'when organistation type is only Funder' do
      before do
        org.funder = true
      end

      it { is_expected.to be true }
    end

    context 'when multiple organistation types present' do
      before do
        org.institution = true
        org.funder = true
      end

      it { is_expected.to be false }
    end
  end

  describe '#to_s' do
    let!(:org) { build(:org) }

    subject { org.to_s }

    it { is_expected.to_not be_blank }
  end

  describe 'short_name' do
    let!(:org) { build(:org) }

    subject { org.short_name }

    context 'when abbreviation present' do
      it { is_expected.to_not be_blank }
    end

    context 'when abbreviation absent' do
      before do
        org.abbreviation = nil
      end

      it { is_expected.to_not be_blank }
    end
  end

  describe '#published_templates' do
    let!(:org) { build(:org) }

    subject { org.published_templates }

    context 'when template is published' do
      before do
        @template = create(:template, published: true, org: org)
      end

      it { is_expected.to include(@template) }
    end

    context 'when template is not published' do
      before do
        @template = create(:template, published: false, org: org)
      end

      it { is_expected.not_to include(@template) }
    end
  end

  describe '#org_admins' do
    let!(:org) { create(:org) }
    let!(:user) { create(:user, org: org) }

    subject { org.org_admins }

    context 'when user belongs to Org with perms absent' do
      before do
        @perm = create(:perm)
        user.org = org
      end

      it { is_expected.to be_empty }
    end

    context 'when user belongs to Org with grant_permissions perm' do
      before do
        @perm = build(:perm)
        @perm.name = 'grant_permissions'
        user.perms << @perm
      end

      it { is_expected.to_not be_empty }
    end

    context 'when user belongs to Org with modify_templates perm' do
      before do
        @perm = build(:perm)
        @perm.name = 'modify_templates'
        user.perms << @perm
      end

      it { is_expected.to_not be_empty }
    end

    context 'when user belongs to Org with modify_guidance perm' do
      before do
        @perm = build(:perm)
        @perm.name = 'modify_guidance'
        user.perms << @perm
      end

      it { is_expected.to_not be_empty }
    end

    context 'when user belongs to Org with change_org_details perm present ' do
      before do
        @perm = build(:perm)
        @perm.name = 'change_org_details'
        user.perms << @perm
      end

      it { is_expected.to_not be_empty }
    end
  end

  describe '#plans' do
    let!(:org) { create(:org) }
    let!(:plan) { create(:plan, org: org) }
    let!(:user) { create(:user, org: org) }

    subject { org.plans }

    context 'when user belongs to Org and plan owner with role :creator' do
      before do
        create(:role, :creator, user: user, plan: plan)
        plan.add_user!(user.id, :creator)
      end

      it { is_expected.to include(plan) }
    end

    context 'when user belongs to Org and plan user with role :administrator' do
      before do
        plan.add_user!(user.id, :administrator)
      end

      it {
        is_expected.to include(plan)
      }
    end

    context 'user belongs to Org and plan user with role :editor, but not :creator and :admin' do
      before do
        plan.add_user!(user.id, :editor)
      end

      it { is_expected.to include(plan) }
    end

    context 'user belongs to Org and plan user with role :commenter, but not :creator and :admin' do
      before do
        plan.add_user!(user.id, :commenter)
      end

      it { is_expected.to include(plan) }
    end

    context 'user belongs to Org and plan user with role :reviewer, but not :creator and :admin' do
      before do
        plan.add_user!(user.id, :reviewer)
      end

      it { is_expected.to include(plan) }
    end
  end

  describe '#org_admin_plans' do
    Rails.configuration.x.plans.org_admins_read_all = true
    let!(:org) { create(:org) }
    let!(:plan) { create(:plan, org: org, visibility: 'publicly_visible') }
    let!(:user) { create(:user, org: org) }

    subject { org.org_admin_plans }

    context 'when user belongs to Org and plan owner with role :creator' do
      before do
        create(:role, :creator, user: user, plan: plan)
        plan.add_user!(user.id, :creator)
      end

      it { is_expected.to include(plan) }
    end

    context 'when user belongs to Org and plan user with role :administrator' do
      before do
        plan.add_user!(user.id, :administrator)
      end

      it {
        is_expected.to include(plan)
      }
    end

    context 'user belongs to Org and plan user with role :editor, but not :creator and :admin' do
      before do
        plan.add_user!(user.id, :editor)
      end

      it { is_expected.to include(plan) }
    end

    context 'user belongs to Org and plan user with role :commenter, but not :creator and :admin' do
      before do
        plan.add_user!(user.id, :commenter)
      end

      it { is_expected.to include(plan) }
    end

    context 'user belongs to Org and plan user with role :reviewer, but not :creator and :admin' do
      before do
        plan.add_user!(user.id, :reviewer)
      end

      it { is_expected.to include(plan) }
    end

    context 'read_all is false, visibility private and user org_admin' do
      before do
        Rails.configuration.x.plans.org_admins_read_all = false
        @perm = build(:perm)
        @perm.name = 'grant_permissions'
        user.perms << @perm
        plan.add_user!(user.id, :reviewer)
        plan.privately_visible!
      end

      it { is_expected.not_to include(plan) }
    end

    context 'read_all is false, visibility public and user org_admin' do
      before do
        Rails.configuration.x.plans.org_admins_read_all = false
        @perm = build(:perm)
        @perm.name = 'grant_permissions'
        user.perms << @perm
        plan.add_user!(user.id, :reviewer)
        plan.publicly_visible!
      end

      it { is_expected.to include(plan) }
    end
  end

  context '#grant_api!' do
    let!(:org) { create(:org) }
    let(:token_permission_type) { create(:token_permission_type) }

    subject { org.grant_api!(token_permission_type) }

    context 'when :token_permission_type does not belong to token_permission_types' do
      it { is_expected.to include(token_permission_type) }
    end

    context 'when :token_permission_type belongs to token_permission_types' do
      before do
        org.token_permission_types << token_permission_type
      end

      it {
        is_expected.to be nil
        expect(org.token_permission_types).to include(token_permission_type)
      }
    end
  end

  describe '#links' do
    it 'returns the contents of the field' do
      links = { org: [{
        link: Faker::Internet.url,
        text: Faker::Lorem.word
      }] }
      org = build(:org, links: links)
      expect(org.links).to eql(JSON.parse(links.to_json))
    end
    it "defaults to {'org': }" do
      org = build(:org)
      expect(org.links).to eql(JSON.parse({ org: [] }.to_json))
    end
  end

  context ':merge!(to_be_merged:)' do
    before(:each) do
      @scheme = create(:identifier_scheme)
      tpt = create(:token_permission_type)
      @org = create(:org, :organisation)

      @to_be_merged = create(:org, :funder, templates: 1, plans: 2, managed: true,
                                            token_permission_types: [tpt])
      create(:annotation, org: @to_be_merged)
      create(:department, org: @to_be_merged)
      gg = @to_be_merged.guidance_groups.first if @to_be_merged.guidance_groups.any?
      gg = create(:guidance_group, org: @to_be_merged) unless gg.present?
      create(:guidance, guidance_group: gg)
      create(:identifier, identifiable: @to_be_merged, identifier_scheme: nil)
      create(:identifier, identifiable: @to_be_merged, identifier_scheme: @scheme)
      create(:plan, funder_id: @to_be_merged.id)
      create(:tracker, org: @to_be_merged)
      create(:user, org: @to_be_merged)
      @to_be_merged.reload
    end

    it 'returns false if to_be_merged is not an Org' do
      result = @org.merge!(to_be_merged: build(:user))
      expect(result).to eql(@org)
    end
    it 'occurs inside a transaction' do
      Org.any_instance.stubs(:save).returns(false)
      result = @org.merge!(to_be_merged: @to_be_merged)
      expect(result).to eql(nil)
      # Since the save will fail and we reload the Object it should be valid
      expect(@org.valid?).to eql(true)
      expect(@to_be_merged.reload.new_record?).to eql(false)
      expect(@to_be_merged.annotations.length).not_to eql(0)
    end
    it 'merges attributes' do
      original = @to_be_merged.dup
      org = @org.merge!(to_be_merged: @to_be_merged)
      expect(org.links).to eql(original.links)
    end
    it 'merges associated :annotations' do
      expected = @org.annotations.length + @to_be_merged.annotations.length
      @org.merge!(to_be_merged: @to_be_merged)
      expect(@org.annotations.length).to eql(expected)
    end
    it 'merges associated :departments' do
      expected = @org.departments.length + @to_be_merged.departments.length
      @org.merge!(to_be_merged: @to_be_merged)
      expect(@org.departments.length).to eql(expected)
    end
    it 'merges associated :funded_plans' do
      expected = @org.funded_plans.length + @to_be_merged.funded_plans.length
      @org.merge!(to_be_merged: @to_be_merged)
      expect(@org.funded_plans.length).to eql(expected)
    end
    it 'merges associated :guidances' do
      expected = (@org.guidance_groups.first&.guidances&.length || 0) +
                 @to_be_merged.guidance_groups.first.guidances.length
      @org.merge!(to_be_merged: @to_be_merged)
      expect(@org.guidance_groups.first.guidances.length).to eql(expected)
    end
    it 'merges associated :identifiers' do
      expected = @org.identifiers.length + @to_be_merged.identifiers.length
      @org.merge!(to_be_merged: @to_be_merged)
      expect(@org.identifiers.length).to eql(expected)
    end
    it 'merges associated :plans' do
      expected = @org.plans.length + @to_be_merged.plans.length
      @org.merge!(to_be_merged: @to_be_merged)
      expect(@org.plans.length).to eql(expected)
    end
    it 'merges associated :templates' do
      expected = @org.templates.length + @to_be_merged.templates.length
      @org.merge!(to_be_merged: @to_be_merged)
      expect(@org.templates.length).to eql(expected)
    end
    it 'merges associated :token_permission_types' do
      expected = (@org.token_permission_types | @to_be_merged.token_permission_types).length
      @org.merge!(to_be_merged: @to_be_merged)
      expect(@org.token_permission_types.length).to eql(expected)
    end
    it 'merges associated :tracker' do
      expected = @to_be_merged.tracker.code
      @org.merge!(to_be_merged: @to_be_merged)
      expect(@org.tracker.code).to eql(expected)
    end
    it 'merges associated :users' do
      expected = @org.users.length + @to_be_merged.users.length
      @org.merge!(to_be_merged: @to_be_merged)
      expect(@org.users.length).to eql(expected)
    end
    it 'removes the :to_be_merged Org' do
      original_id = @to_be_merged.id
      expect(@org.merge!(to_be_merged: @to_be_merged)).to eql(@org)
      expect(Org.find_by(id: original_id).present?).to eql(false)
    end
  end

  context 'private methods' do
    describe ':merge_attributes!(to_be_merged:)' do
      before(:each) do
        @org = create(:org, :organisation, is_other: false, managed: false,
                                           feedback_enabled: false, contact_email: nil,
                                           contact_name: nil, feedback_msg: nil)

        @to_be_merged = create(:org, :funder, templates: 1, plans: 2, managed: true,
                                              feedback_enabled: true,
                                              is_other: true,
                                              region: create(:region),
                                              language: create(:language, abbreviation: 'org-mdl'))
      end

      it 'returns false unless Org is an Org' do
        expect(@org.send(:merge_attributes!, to_be_merged: create(:user))).to eql(false)
      end
      it 'merges the correct attributes' do
        original = @to_be_merged.dup
        org = @org.merge!(to_be_merged: @to_be_merged)
        expect(org.managed?).to eql(original.managed?)
        expect(org.links).to eql(original.links)
        expect(org.target_url).to eql(original.target_url)
        expect(org.logo).to eql(original.logo)
        expect(org.contact_email).to eql(original.contact_email)
        expect(org.contact_name).to eql(original.contact_name)
        expect(org.feedback_enabled).to eql(original.feedback_enabled)
        expect(org.feedback_msg).to eql(original.feedback_msg)
      end
      it 'does not merge the attributes it should not merge' do
        original = @to_be_merged.dup
        org = @org.merge!(to_be_merged: @to_be_merged)
        expect(org.abbreviation).not_to eql(original.abbreviation)
        expect(org.name).not_to eql(original.name)
        expect(org.organisation?).to eql(true)
        expect(org.funder?).to eql(false)
        expect(org.region).not_to eql(original.region)
        expect(org.language).not_to eql(original.language)
      end
    end

    describe ':merge_departments!(to_be_merged:)' do
      before(:each) do
        @org = create(:org)
        @to_be_merged = create(:org)
        @department = create(:department, org: @to_be_merged)
        @to_be_merged.reload
      end

      it 'returns false unless the specified Org is an Org' do
        expect(@org.send(:merge_departments!, to_be_merged: create(:user))).to eql(false)
      end
      it 'returns false unless the specified Org has department' do
        expect(@org.send(:merge_departments!, to_be_merged: create(:org))).to eql(false)
      end
      it 'merges :departments that are not already associated' do
        @org.send(:merge_departments!, to_be_merged: @to_be_merged)
        @org.reload
        expect(@org.departments.map(&:name).include?(@department.name)).to eql(true)
      end
      it 'does not merge :departments that have the same name' do
        create(:department, name: @department.name.downcase, org: @org)
        @org.reload
        @org.send(:merge_departments!, to_be_merged: @to_be_merged)
        expect(@org.departments.length).to eql(1)
      end
    end

    describe ':merge_guidance_groups!(to_be_merged:)' do
      before(:each) do
        @guidance = create(:guidance)
        @gg = create(:guidance_group, guidances: [@guidance])
        @org = create(:org, guidance_groups: [])
        @to_be_merged = create(:org, guidance_groups: [@gg])
      end

      it 'returns false unless the specified Org is an Org' do
        expect(@org.send(:merge_guidance_groups!, to_be_merged: create(:user))).to eql(false)
      end
      it 'returns false unless the specified Org has :guidance_groups' do
        expect(@org.send(:merge_guidance_groups!, to_be_merged: create(:org))).to eql(false)
      end
      it "merges into the Org's existing :guidance_group" do
        @org.update(guidance_groups: [create(:guidance_group, guidances: [])])
        @org.send(:merge_guidance_groups!, to_be_merged: @to_be_merged)
        @org = @org.reload
        expect(@org.guidance_groups.include?(@gg)).to eql(false)
        expect(@org.guidance_groups.length).to eql(1)
        expect(@org.guidance_groups.first.guidances.include?(@guidance)).to eql(true)
      end
      it 'creates a new :guidance_group if the Org does not have one' do
        @org.send(:merge_guidance_groups!, to_be_merged: @to_be_merged)
        @org = @org.reload
        expect(@org.guidance_groups.include?(@gg)).to eql(false)
        expect(@org.guidance_groups.length).to eql(1)
        expect(@org.guidance_groups.first.guidances.include?(@guidance)).to eql(true)
      end
    end

    describe ':merge_token_permission_types!(to_be_merged:)' do
      before(:each) do
        @tpt = create(:token_permission_type)
        @org = create(:org)
        @to_be_merged = create(:org, token_permission_types: [@tpt])
      end

      it 'returns false unless the specified Org is an Org' do
        expect(@org.send(:merge_token_permission_types!, to_be_merged: create(:user))).to eql(false)
      end
      it 'returns false unless the specified Org has token_permission_types' do
        o = create(:org)
        # when org is created tpt gets assigned by default so need to scrub for this test
        o.token_permission_types = []
        expect(@org.send(:merge_token_permission_types!, to_be_merged: o)).to eql(false)
      end
      it 'merges :token_permission_types that are not already associated' do
        @org.send(:merge_token_permission_types!, to_be_merged: @to_be_merged)
        expect(@org.token_permission_types.include?(@tpt)).to eql(true)
      end
      it 'does not merge :token_permission_types that are already associated' do
        @org.update(token_permission_types: [@tpt])
        @org.send(:merge_token_permission_types!, to_be_merged: @to_be_merged)
        expect(@org.token_permission_types.length).to eql(1)
      end
    end
  end
end
