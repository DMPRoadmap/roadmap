# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Template, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to allow_values(true, false).for(:published) }

    # This is currently being set in the defaults before validation
    # it { is_expected.not_to allow_value(nil).for(:published) }

    it { is_expected.to validate_presence_of(:org) }

    it { is_expected.to validate_presence_of(:locale) }

    it { is_expected.to allow_values(true, false).for(:is_default) }

    # This is currently being set in the defaults before validation
    # it { is_expected.not_to allow_value(nil).for(:is_default) }

    # This is currently being set in the defaults before validation
    # it { is_expected.to validate_presence_of(:version) }

    # This is currently being set in the defaults before validation
    # it { is_expected.to validate_presence_of(:visibility) }

    # This is currently being set in the defaults before validation
    # it { is_expected.to validate_presence_of(:family_id) }

    it { is_expected.to allow_values(true, false).for(:archived) }

    # This is currently being set in the defaults before validation
    # it { is_expected.not_to allow_value(nil).for(:archived) }
  end

  context 'associations' do
    it { is_expected.to belong_to :org }

    it { is_expected.to have_many :plans }

    it { is_expected.to have_many :phases }

    it { is_expected.to have_many :sections }

    it { is_expected.to have_many :questions }

    it { is_expected.to have_many :question_options }

    it { is_expected.to have_many :conditions }

    it { is_expected.to have_many :annotations }
  end

  describe '.archived' do
    subject { Template.archived }

    context 'when template is archived' do
      let!(:template) { create(:template, archived: true) }

      it { is_expected.to include(template) }
    end

    context 'when template is archived' do
      let!(:template) { create(:template, archived: false) }

      it { is_expected.not_to include(template) }
    end
  end

  describe '.unarchived' do
    subject { Template.unarchived }

    context 'when template is archived' do
      let!(:template) { create(:template, archived: true) }

      it { is_expected.not_to include(template) }
    end

    context 'when template is archived' do
      let!(:template) { create(:template, archived: false) }

      it { is_expected.to include(template) }
    end
  end

  describe '.default' do
    subject { Template.default }

    context 'when default published template exists' do
      before do
        @a = create(:template, :default, :published)
        @b = create(:template, :default, :published)
      end

      it 'returns the latest record' do
        expect(subject).to eql(@b)
      end
    end

    context 'when default template is not published' do
      before do
        create(:template, :default, :unpublished)
      end

      it 'returns nil' do
        is_expected.to be_nil
      end
    end

    context 'when none of the published templates are default' do
      before do
        create(:template, :published, is_default: false)
      end

      it 'returns nil' do
        is_expected.to be_nil
      end
    end
  end

  describe '.latest_version' do
    let!(:family_id) { nil }

    subject { Template.latest_version(family_id) }

    it 'returns an ActiveRecord::Relation' do
      expect(subject).to be_a(ActiveRecord::Relation)
    end

    context 'when family_id is present' do
      let!(:family_id) { '1235' }

      let!(:template) do
        create(:template, :unpublished, family_id: '1235', version: 12)
      end

      before do
        create(:template, :unpublished, family_id: '1235', version: 11)
        create(:template, :unpublished, family_id: '9999', version: 13)
      end

      it 'filters results by family_id' do
        expect(subject).to include(template)
      end
    end

    context 'when family_id is absent' do
      let!(:family_id) { nil }

      let!(:template) { create(:template, :unpublished, version: 12) }

      before do
        create(:template, :unpublished, version: 11)
        create(:template, :unpublished, version: 10)
      end

      it 'returns the ' do
        expect(subject).to include(template)
      end
    end

    context 'when template is archived' do
      let!(:family_id) { nil }

      let!(:template) { create(:template, :archived, :unpublished, version: 12) }

      before do
        @a = create(:template, :unpublished, version: 11)
        @b = create(:template, :unpublished, version: 10)
      end

      it 'excludes from the results' do
        expect(subject).not_to include(template)
      end
    end
  end

  describe '.published' do
    subject { Template.published(family_id_search) }

    before do
      @a = create(:template, :published, family_id: family_id_set, version: 1)
      @b = create(:template, :published, version: 3)
      @c = create(:template, :unpublished, family_id: family_id_set, version: 2)
      @d = create(:template, :unpublished, version: 5)
    end

    context 'when family_id is present' do
      let!(:family_id_search) { '1234' }
      let!(:family_id_set) { '1234' }

      it 'includes records with family id' do
        expect(subject).to include(@a)
      end

      it 'excludes records without family id' do
        expect(subject).not_to include(@b)
      end

      it 'excludes unpublished records' do
        expect(subject).not_to include(@c)
        expect(subject).not_to include(@d)
      end
    end

    context 'when family_id is absent' do
      let!(:family_id_search) { nil }
      let!(:family_id_set) { '1234' }

      it 'includes all published records' do
        expect(subject).to include(@a)
        expect(subject).to include(@b)
      end

      it 'excludes all published records' do
        expect(subject).not_to include(@c)
        expect(subject).not_to include(@d)
      end
    end
  end

  describe '.latest_customized_version' do
    let!(:original_template) { create(:template) }

    let!(:family_id) { original_template.family_id }

    let!(:org) { create(:org) }

    subject { Template.latest_customized_version(family_id, org.id) }

    context 'when latest version present' do
      before do
        create(:template, customization_of: family_id, org: org, version: 5)
        create(:template, customization_of: family_id, org: org, version: 6)
      end

      it 'returns a single record' do
        expect(subject).to be_one
      end

      it 'returns the correct version' do
        expect(subject.last.version).to eql(6)
      end
    end

    context 'when latest version absent' do
      before do
        create(:template, customization_of: '1234', org: org, version: 5)
        create(:template, customization_of: '1234', org: org, version: 6)
      end

      it 'returns an empty set' do
        expect(subject).to be_empty
      end
    end

    context 'when latest version belongs to different Org' do
      before do
        create(:template, customization_of: family_id, version: 5)
        create(:template, customization_of: family_id, version: 6)
      end

      it 'returns an empty set' do
        expect(subject).to be_empty
      end
    end

    context 'when latest version is archived' do
      before do
        create(:template, customization_of: family_id, org: org, version: 5)
        create(:template, :archived, customization_of: family_id, org: org, version: 6)
      end

      # TODO: Confirm: Is this the desired behaviour?
      it 'returns an empty set' do
        expect(subject).to be_empty
      end
    end
  end

  describe '.latest_version_per_org' do
    context 'when org_id is an Integer' do
      let!(:org) { create(:org) }

      subject { Template.latest_version_per_org(org.id) }

      before do
        @a = create(:template, org: org, version: 1, family_id: 123)
        @b = create(:template, org: org, version: 2, family_id: 123)
        @c = create(:template, org: org, version: 2, family_id: 456)
        @d = create(:template, org: org, version: 1, family_id: 456)
      end

      it { is_expected.not_to include(@a) }

      it { is_expected.to include(@b) }

      it { is_expected.to include(@c) }

      it { is_expected.not_to include(@d) }
    end

    context 'when org_id is an Array' do
      let!(:org_a) { create(:org) }

      let!(:org_b) { create(:org) }

      subject { Template.latest_version_per_org([org_a.id, org_b.id]) }

      before do
        @a = create(:template, org: org_a, version: 1, family_id: 123)
        @b = create(:template, org: org_a, version: 2, family_id: 123)
        @c = create(:template, org: org_b, version: 2, family_id: 456)
        @d = create(:template, org: org_b, version: 1, family_id: 456)
      end

      it { is_expected.not_to include(@a) }

      it { is_expected.to include(@b) }

      it { is_expected.to include(@c) }

      it { is_expected.not_to include(@d) }
    end
  end

  describe '.latest_customized_version_per_org' do
    let!(:original_template) { create(:template) }

    let!(:family_id) { original_template.family_id }

    let!(:org) { create(:org) }

    subject { Template.latest_customized_version_per_org(org.id) }

    context 'when latest version present' do
      before do
        create(:template, customization_of: family_id, org: org, version: 5)
        create(:template, customization_of: family_id, org: org, version: 6)
      end

      it 'returns a single record' do
        expect(subject).to be_one
      end

      it 'returns the correct version' do
        expect(subject.last.version).to eql(6)
      end
    end

    context 'when latest version absent' do
      before do
        create(:template, customization_of: '1234', org: org, version: 5)
        create(:template, customization_of: '1234', org: org, version: 6)
      end

      it 'returns an empty set' do
        expect(subject).to be_empty
      end
    end

    context 'when latest version belongs to different Org' do
      before do
        create(:template, customization_of: family_id, version: 5)
        create(:template, customization_of: family_id, version: 6)
      end

      it 'returns an empty set' do
        expect(subject).to be_empty
      end
    end

    context 'when latest version is archived' do
      before do
        create(:template, customization_of: family_id, org: org, version: 5)
        create(:template, :archived, customization_of: family_id, org: org, version: 6)
      end

      # TODO: Confirm: Is this the desired behaviour?
      it 'returns an empty set' do
        expect(subject).to be_empty
      end
    end
  end

  describe '.families' do
    context 'when org_id is given' do
      let!(:org) { create(:org) }

      subject { Template.families([org.id]) }

      before do
        @a = create(:template, customization_of: nil)
        @b = create(:template, customization_of: nil, org: org)
        @c = create(:template, :archived, customization_of: nil, org: org)
      end

      it 'excludes Templates belonging to other Orgs' do
        expect(subject).not_to include(@a)
      end

      it 'includes Templates that are not customisations' do
        expect(subject).to include(@b)
      end

      it 'excludes archived Templates' do
        expect(subject).not_to include(@c)
      end
    end

    context 'when org_id is nil' do
      subject { Template.families(nil) }

      before do
        @a = create(:template, customization_of: nil)
        @b = create(:template, customization_of: '123')
        @c = create(:template, :archived, customization_of: nil)
      end

      it 'includes Templates belonging to all Orgs' do
        expect(subject).to include(@a)
      end

      it 'excludes Templates that are customizations' do
        expect(subject).not_to include(@b)
      end

      it 'excludes archived Templates' do
        expect(subject).not_to include(@c)
      end
    end
  end

  describe '.latest_customizable' do
    before do
      create(:org, is_other: true) unless Org.where(is_other: true).any?
      create(:template, :default, :published)
    end

    let!(:template) { create(:template, :published, :publicly_visible, org: org) }

    subject { Template.latest_customizable }

    context 'when Org is an institution' do
      let!(:org) { create(:org, :institution) }

      it { is_expected.not_to include(template) }
    end

    context 'when Org is a funder' do
      let!(:org) { create(:org, :funder) }

      it { is_expected.to include(template) }
    end

    context 'when Org is an organisation' do
      let!(:org) { create(:org, :organisation) }

      it { is_expected.not_to include(template) }
    end

    context 'when Org is a research_institute' do
      let!(:org) { create(:org, :research_institute) }

      it { is_expected.not_to include(template) }
    end

    context 'when Org is a project' do
      let!(:org) { create(:org, :project) }

      it { is_expected.not_to include(template) }
    end

    context 'when Org is a school' do
      let!(:org) { create(:org, :school) }

      it { is_expected.not_to include(template) }
    end

    context 'when template is default and published' do
      let!(:template) { create(:template, :default, :published) }

      it { is_expected.to include(template) }
    end

    context 'when template is default and unpublished' do
      let!(:template) { create(:template, :default, :unpublished) }

      it { is_expected.not_to include(template) }
    end
  end

  describe '.publicly_visible' do
    subject { Template.publicly_visible }

    before do
      @a = create(:template, :archived, :publicly_visible)
      @b = create(:template, :publicly_visible)
      @c = create(:template, :organisationally_visible)
    end

    it 'excludes archived Templates' do
      # The enum is currently overwriting this scope
      expect(subject).not_to include(@a)
    end

    it 'includes publicly_visible Templates' do
      expect(subject).to include(@b)
    end

    it 'excludes organisationally_visible Templates' do
      expect(subject).not_to include(@c)
    end
  end

  describe '.organisationally_visible' do
    subject { Template.organisationally_visible }

    before do
      @a = create(:template, :archived, :organisationally_visible)
      @b = create(:template, :publicly_visible)
      @c = create(:template, :organisationally_visible)
    end

    it 'excludes archived Templates' do
      # The enum is currently overwriting this scope
      expect(subject).not_to include(@a)
    end

    it 'excludes publicly_visible Templates' do
      expect(subject).not_to include(@b)
    end

    it 'includes organisationally_visible Templates' do
      expect(subject).to include(@c)
    end
  end

  describe '.search' do
    subject { Template.search('foo') }

    before do
      @a = create(:template, :archived, title: 'foo bar')
      @b = create(:template, title: 'foo bar')
      @c = create(:template, description: '<p>foo bar</p>')
      @d = create(:template, org: create(:org, name: 'foo org'))
    end

    it 'excludes archived Templates' do
      expect(subject).not_to include(@a)
    end

    it 'includes Templates with a matching title' do
      expect(subject).to include(@b)
    end

    it 'excludes Templates with a matching description' do
      expect(subject).not_to include(@c)
    end

    it 'includes Templates with a matching Org name' do
      expect(subject).to include(@d)
    end
  end

  describe '.current' do
    subject { Template.current('1234') }

    before do
      @a = create(:template, :archived, family_id: '1234', version: 5)
      @b = create(:template, family_id: '5555', version: 2)
      @c = create(:template, family_id: '1234', version: 2)
    end

    it 'excludes archived Templates' do
      expect(subject).not_to eql(@a)
    end

    it 'excludes Templates with a different family_id' do
      expect(subject).not_to eql(@b)
    end

    it 'orders results by DESC version' do
      expect(subject).to eql(@c)
    end
  end

  describe '.live' do
    context 'when family ID is an Array' do
      subject { Template.live([1234, 1235]) }

      before do
        @a = create(:template, :archived, :published, family_id: 1234)
        @b = create(:template, :published, family_id: 1234)
        @c = create(:template, :unpublished, family_id: 1234)
        @d = create(:template, :published, family_id: 1235)
      end

      it 'returns an enumerable' do
        expect(subject).to be_a(ActiveRecord::Relation)
      end

      it 'excludes archived Templates' do
        expect(subject).not_to include(@a)
      end

      it 'includes published Templates' do
        expect(subject).to include(@b)
      end

      it 'excludes unpublished Templates' do
        expect(subject).not_to include(@c)
      end

      it 'includes published Templates' do
        expect(subject).to include(@d)
      end
    end

    context 'when family ID is an Integer' do
      subject { Template.live(1234) }

      before do
        @a = create(:template, :archived, :published, family_id: 1234)
        @b = create(:template, :published, family_id: 1234)
        @c = create(:template, :unpublished, family_id: 1234)
        @d = create(:template, :published, family_id: 1235)
      end

      it 'excludes archived Templates' do
        expect(subject).not_to eql(@a)
      end

      it 'includes published Templates' do
        expect(subject).to eql(@b)
      end

      it 'excludes unpublished Templates' do
        expect(subject).not_to eql(@c)
      end

      it 'excludes published Templates with other family_id' do
        expect(subject).not_to eql(@d)
      end
    end
  end

  describe '.find_or_generate_version!' do
    subject { Template.find_or_generate_version!(template) }

    context 'when template is not latest?' do
      let!(:template) { create(:template) }

      before do
        template.expects(:latest?).at_least(1).returns(false)
      end

      it 'raises an error' do
        expect { subject }.to raise_error(StandardError)
      end
    end

    context 'when template is latest and generate_version? is true' do
      let!(:template) { create(:template, :published) }

      before do
        template.expects(:latest?).at_least(1).returns(true)
      end

      it 'returns a different Template' do
        expect(subject).not_to eql(template)
      end

      it 'creates a persisted Template' do
        expect(subject).to be_persisted
      end
    end

    context 'when template is latest and generate_version? is false' do
      let!(:template) { create(:template, :unpublished) }

      before do
        template.expects(:latest?).at_least(1).returns(true)
      end

      it 'returns the same Template' do
        expect(subject).to eql(template)
      end
    end
  end

  describe '#deep_copy' do
    context 'when attributes is provided' do
      let!(:template) { create(:template, :published, phases: 2) }

      subject do
        template.deep_copy(attributes: { title: 'foo', description: 'bar' })
      end

      it 'updates title with the provided value' do
        expect(subject.title).to eql('foo')
      end

      it 'updates describe with the provided value' do
        expect(subject.description).to eql('bar')
      end
    end

    context 'when options save is true' do
      let!(:template) { create(:template, :published, phases: 2) }

      subject { template.deep_copy(attributes: { family_id: 123 }, save: true) }

      it 'returns a persisted record' do
        expect(subject).to be_persisted
      end

      it 'creates phases' do
        expect(subject.phases).to be_many
      end

      it 'sets template_id on phases to the new template' do
        new_temp = subject
        expect(new_temp.phases.map(&:template_id).uniq).to eql([new_temp.id])
      end
    end

    context 'when options save is false' do
      let!(:template) { create(:template, :published, phases: 2) }

      subject { template.deep_copy(attributes: { family_id: 123 }, save: false) }

      it 'returns a new record' do
        expect(subject).to be_new_record
      end

      it 'builds phases' do
        expect(subject.phases).to be_many
      end

      it "doesn't set template_id on phases" do
        expect(subject.phases.map(&:template_id).compact).to be_empty
      end
    end
  end

  describe '#base_org' do
    subject { template.base_org }

    context 'when customization_of is present' do
      let!(:source_template) { create(:template) }

      let!(:template) do
        create(:template, customization_of: source_template.family_id)
      end

      it 'returns the source Template org' do
        expect(subject).to eql(source_template.org)
      end
    end

    context 'when customization_of is not present' do
      let!(:template) { create(:template, customization_of: nil) }

      it 'returns the base Template org' do
        expect(subject).to eql(template.org)
      end
    end
  end

  describe '#latest?' do
    context 'when Template is the latest in its family' do
      let!(:template) do
        create(:template, :published, version: 5, family_id: 123)
      end

      it 'returns true' do
        expect(template).to be_latest
      end
    end

    context 'when Template is not the latest in its family' do
      let!(:template) do
        create(:template, :published, version: 5, family_id: 123)
      end

      before do
        create(:template, :published, version: 6, family_id: 123)
      end

      it 'returns false' do
        expect(template).not_to be_latest
      end
    end
  end

  describe '#generate_version?' do
    let!(:template) { build(:template) }

    subject { template.generate_version? }

    context 'when published is true' do
      before do
        template.published = true
      end

      it { is_expected.to eql(true) }
    end

    context 'when published is false' do
      before do
        template.published = false
      end

      it { is_expected.to eql(false) }
    end
  end

  describe '#customize?' do
    subject { template.customize?(org) }

    context "when param is Org, org is funder, customization doesn't exist" do
      let!(:org) { create(:org, :funder) }

      let!(:template) { create(:template, org: org) }

      it { is_expected.to eql(true) }
    end

    context "when param is Org, template default, customization doesn't exist" do
      let!(:org) { create(:org) }

      let!(:template) { create(:template, :default, org: org) }

      it { is_expected.to eql(true) }
    end

    context 'when param is Org, org is funder, customization exists' do
      let!(:org) { create(:org, :funder) }

      let!(:template) { create(:template, org: org) }

      before do
        create(:template, customization_of: template.family_id, org: org)
      end

      it { is_expected.to eql(false) }
    end

    context 'when param is Org, template default, customization exists' do
      let!(:org) { create(:org) }

      let!(:template) { create(:template, :default, org: org) }

      before do
        create(:template, customization_of: template.family_id, org: org)
      end

      it { is_expected.to eql(false) }
    end

    context 'when param not Org' do
      let!(:org) { build(:plan) }

      let!(:template) { create(:template, org: create(:org, :funder)) }

      it { is_expected.to eql(false) }
    end
  end

  describe '#upgrade_customization?' do
    let!(:org) { create(:org, :funder) }

    context 'when not a customization of another template' do
      let!(:template) do
        create(:template, :published, customization_of: nil, org: org)
      end

      it { expect(template).not_to be_upgrade_customization }
    end

    context 'when customization of another template and source is newer' do
      let!(:source) do
        create(:template, :published,
               family_id: 123, org: org, created_at: 1.minutes.from_now)
      end

      let!(:template) do
        create(:template, :published, customization_of: source.family_id)
      end

      it { expect(template).to be_upgrade_customization }
    end

    context 'when customization of another template and source is older' do
      let!(:source) do
        create(:template, :published, family_id: 123, org: org, created_at: 1.minutes.ago)
      end

      let!(:template) do
        create(:template, :published, customization_of: source.family_id)
      end

      it { expect(template).not_to be_upgrade_customization }
    end
  end

  describe '#draft?' do
    subject { template.draft? }

    context 'when published and family has published template' do
      let!(:template) { create(:template, :published) }

      before do
        create(:template, :published, family_id: template.family_id)
      end

      it { is_expected.to eql(false) }
    end

    context 'when published and family has no published template' do
      let!(:template) { create(:template, :published) }

      before do
        create(:template, :unpublished, family_id: template.family_id)
      end

      it { is_expected.to eql(false) }
    end

    context 'when unpublished and family has published template' do
      let!(:template) { create(:template, :unpublished) }

      before do
        create(:template, :published, family_id: template.family_id)
      end

      it { is_expected.to eql(true) }
    end

    context 'when unpublished and family has no published template' do
      let!(:template) { create(:template, :unpublished) }

      before do
        create(:template, :unpublished, family_id: template.family_id)
      end

      it { is_expected.to eql(false) }
    end
  end

  describe '#removable?' do
    let!(:template) { create(:template) }

    context 'when there are no Plans using this Template' do
      it { expect(template).to be_removable }
    end

    context 'when there Plans using this Template' do
      before do
        create(:plan, template: template)
      end

      it { expect(template).not_to be_removable }
    end

    context 'when there are Plans, but using different Templates' do
      before do
        create(:plan)
      end

      it { expect(template).to be_removable }
    end
  end

  describe '#generate_copy!' do
    subject { template.generate_copy!(org) }

    let!(:template) { create(:template) }

    context 'when org is not an Org' do
      let!(:org) { build(:plan) }

      it 'raises a StandardError' do
        expect { subject }.to raise_error(StandardError)
      end
    end

    context 'when org is an Org record' do
      let!(:org) { create(:org) }

      it 'sets the version to zero' do
        expect(subject.version).to be_zero
      end

      it 'sets published to false' do
        expect(subject.published).to eql(false)
      end

      it 'sets family_id to a new integer' do
        expect(subject.family_id).to be_a(Integer)
      end

      it 'sets org to new org' do
        expect(subject.org).to eql(org)
      end

      it 'sets is_default to false' do
        expect(subject.is_default).to eql(false)
      end

      it "sets title to include 'Copy of'" do
        expect(subject.title).to include('Copy of')
      end

      it 'sets title to include original title' do
        expect(subject.title).to include(template.title)
      end
    end
  end

  describe '#generate_version!' do
    subject { template.generate_version! }

    context 'when template is not published' do
      let!(:template) { create(:template, :unpublished) }

      it 'raises a StandardError' do
        expect { subject }.to raise_error(StandardError)
      end
    end

    context 'when Template is published' do
      let!(:template) do
        create(:template, :published, version: 4)
      end

      it 'sets the version to current version plus one' do
        expect(subject.version).to eql(5)
      end

      it 'sets published to false' do
        expect(subject.published).to eql(false)
      end

      it 'sets org to new org' do
        expect(subject.org).to eql(template.org)
      end
    end
  end

  describe '#customize!' do
    subject { template.customize!(org) }

    # Added an additional type to Org so that funder_only? fails
    let!(:org) { create(:org, :funder, :organisation) }

    let!(:template) { create(:template, :default, org: org) }

    it 'sets the version to 0' do
      expect(subject.version).to be_zero
    end

    it 'sets the published to false' do
      expect(subject.published).to eql(false)
    end

    it 'sets the family_id to a new Integer' do
      expect(subject.family_id).not_to eql(template.family_id)
    end

    it "sets customization of to Template's family_id" do
      expect(subject.customization_of).to eql(template.family_id)
    end

    it "sets org to Template's org" do
      expect(subject.org).to eql(template.org)
    end

    it 'sets visibility to Organisationally visible' do
      expect(subject.visibility).to eql(Template.visibilities['organisationally_visible'])
    end

    it 'sets is_default to false' do
      expect(subject.is_default).to eql(false)
    end

    context 'when org is not an Org' do
      let!(:org) { stubs(:org) }

      let!(:template) { create(:template) }

      it 'raises an exception' do
        expect { subject }.to raise_error(StandardError)
      end
    end

    context 'when org is not funder only' do
      let!(:org) { create(:org, :school) }

      let!(:template) { create(:template, org: org) }

      it 'raises an exception' do
        expect { subject }.to raise_error(StandardError)
      end
    end
  end

  describe '#upgrade_customization!' do
    subject { template.upgrade_customization! }

    let!(:source) do
      create(:template, :published, phases: 3)
    end

    let!(:template) do
      create(:template, :published,
             version: 5, customization_of: source.family_id)
    end

    it 'returns a Template' do
      expect(subject).to be_a(Template)
    end

    it 'returns a persisted Template' do
      expect(subject).to be_persisted
    end

    it 'sets the version to template version plus one' do
      expect(subject.version).to eql(6)
    end

    it 'sets the published to false' do
      expect(subject.published).to eql(false)
    end

    it "sets the family_id to template's family ID" do
      expect(subject.family_id).to eql(template.family_id)
    end

    it "sets the customization_of to template's customization_of" do
      expect(subject.customization_of).to eql(template.customization_of)
    end

    it "sets the org to Template's org" do
      expect(subject.org).to eql(template.org)
    end

    it 'sets the visibility to Organisationally visible' do
      expect(subject.visibility).to eql(Template.visibilities['organisationally_visible'])
    end

    it 'sets is_default to false' do
      expect(subject.is_default).to eql(false)
    end

    it 'sets phases modifiable to false' do
      subject.phases.each do |phase|
        expect(phase.modifiable).to eql(false)
      end
    end

    context 'when customization_of is blank' do
      let!(:template) { create(:template, customization_of: nil) }

      it 'raises an error' do
        expect { subject }.to raise_error(StandardError)
      end
    end

    context 'when source Template is not present' do
      let!(:template) do
        create(:template, :published, customization_of: 456)
      end

      it 'raises an error' do
        expect { subject }.to raise_error(StandardError)
      end
    end
  end

  describe '#publishability' do
    subject { template.publishability }

    # Added an additional type to Org so that funder_only? fails
    let!(:org) { create(:org, :funder, :organisation) }

    # let!(:template) { create(:template, :default, org: org) }

    # case when template is correctly generated
    context 'When the Template has all components, is latest, and unpublished' do
      let(:template) do
        create(:template, :default, published: false, org: org, phases: 1,
                                    sections: 1, questions: 1)
      end

      it 'returns true' do
        expect(subject[0]).to eql(true)
      end

      it 'has no errors' do
        expect(subject[1]).to eql('')
      end
    end

    # case when the template is historical
    context 'When the template is an historical version' do
      let(:template) do
        create(:template, :default, published: true, org: org, phases: 3,
                                    version: 1, sections: 1, questions: 1)
      end

      before do
        template.generate_version!
        template.update_column(:published, false)
      end

      it 'returns false' do
        expect(subject[0]).to eql(false)
      end

      it 'has error_message' do
        expected = 'You can not publish a historical version of this template.  '
        expect(subject[1]).to include(expected)
      end
    end

    # case when the template is published
    context 'When the Template has all components, is latest, and already published' do
      let(:template) do
        create(:template, :default, published: true, org: org, phases: 1,
                                    sections: 1, questions: 1)
      end

      it 'is not publishable' do
        expect(subject[0]).to eql(false)
      end

      it 'has error_message' do
        expect(subject[1]).to include('You can not publish a published template.')
      end
    end
    # case when template has no phases
    context 'When the Template has no phases' do
      let(:template) { create(:template, :default, published: true, org: org, phases: 0) }

      it 'is not publishable' do
        expect(subject[0]).to eql(false)
      end

      it 'has error_message' do
        expect(subject[1]).to include('You can not publish a template without phases')
      end
    end
    # case when a template has no sections
    context 'When the Template has no sections' do
      let(:template) do
        create(:template, :default, published: true, org: org, phases: 1, sections: 0)
      end

      it 'is not publishable' do
        expect(subject[0]).to eql(false)
      end

      it 'has error_message' do
        expect(subject[1]).to include('You can not publish a template without sections in a phase')
      end
    end
    # case when a section has no questions
    context 'When the Template has no questions' do
      let(:template) do
        create(:template, :default, published: true, org: org, phases: 1,
                                    sections: 1, questions: 0)
      end

      it 'is not publishable' do
        expect(subject[0]).to eql(false)
      end

      it 'has error_message' do
        expected = 'You can not publish a template without questions in a section'
        expect(subject[1]).to include(expected)
      end
    end
  end
end
