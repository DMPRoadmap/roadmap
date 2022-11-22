# frozen_string_literal: true

require 'rails_helper'

def recreate_all
  # create records..
  %w[
    add_organisations
    change_org_affiliation
    grant_permissions
    modify_templates
    modify_guidance
    use_api
    change_org_details
    grant_api_to_orgs
    review_org_plans
  ].each do |name|
    create(:perm, name: name)
  end
end

RSpec.describe Perm do
  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it {
      expect(subject).to validate_uniqueness_of(:name).case_insensitive
                                                      .with_message('must be unique')
    }
  end

  context 'associations' do
    it { is_expected.to have_and_belong_to_many(:users) }
  end

  describe '.add_orgs' do
    subject { described_class.add_orgs }

    before do
      recreate_all
    end

    context "when name is 'add_orgs'" do
      it { is_expected.to eql(described_class.find_by(name: 'add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'grant_api_to_orgs')) }
    end
  end

  describe '.change_affiliation' do
    subject { described_class.change_affiliation }

    before do
      recreate_all
    end

    context "when name is 'add_orgs'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.to eql(described_class.find_by(name: 'change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'grant_api_to_orgs')) }
    end
  end

  describe '.grant_permissions' do
    subject { described_class.grant_permissions }

    before do
      recreate_all
    end

    context "when name is 'add_orgs'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.to eql(described_class.find_by(name: 'grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'grant_api_to_orgs')) }
    end
  end

  describe '.modify_templates' do
    subject { described_class.modify_templates }

    before do
      recreate_all
    end

    context "when name is 'add_orgs'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.to eql(described_class.find_by(name: 'modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'grant_api_to_orgs')) }
    end
  end

  describe '.modify_guidance' do
    subject { described_class.modify_guidance }

    before do
      recreate_all
    end

    context "when name is 'add_orgs'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.to eql(described_class.find_by(name: 'modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'grant_api_to_orgs')) }
    end
  end

  describe '.use_api' do
    subject { described_class.use_api }

    before do
      recreate_all
    end

    context "when name is 'add_orgs'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.to eql(described_class.find_by(name: 'use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'grant_api_to_orgs')) }
    end
  end

  describe '.change_org_details' do
    subject { described_class.change_org_details }

    before do
      recreate_all
    end

    context "when name is 'add_orgs'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.to eql(described_class.find_by(name: 'change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'grant_api_to_orgs')) }
    end
  end

  describe '.grant_api' do
    subject { described_class.grant_api }

    before do
      recreate_all
    end

    context "when name is 'add_orgs'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.not_to eql(described_class.find_by(name: 'change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.to eql(described_class.find_by(name: 'grant_api_to_orgs')) }
    end
  end
end
