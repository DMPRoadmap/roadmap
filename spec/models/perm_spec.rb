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

RSpec.describe Perm, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it {
      is_expected.to validate_uniqueness_of(:name).case_insensitive
                                                  .with_message('must be unique')
    }
  end

  context 'associations' do
    it { is_expected.to have_and_belong_to_many(:users) }
  end

  describe '.add_orgs' do
    before(:each) do
      recreate_all
    end

    subject { Perm.add_orgs }

    context "when name is 'add_orgs'" do
      it { is_expected.to eql(Perm.find_by_name('add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.not_to eql(Perm.find_by_name('change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.not_to eql(Perm.find_by_name('grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.not_to eql(Perm.find_by_name('modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.not_to eql(Perm.find_by_name('modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.not_to eql(Perm.find_by_name('use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.not_to eql(Perm.find_by_name('change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.not_to eql(Perm.find_by_name('grant_api_to_orgs')) }
    end
  end

  describe '.change_affiliation' do
    before(:each) do
      recreate_all
    end

    subject { Perm.change_affiliation }

    context "when name is 'add_orgs'" do
      it { is_expected.not_to eql(Perm.find_by_name('add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.to eql(Perm.find_by_name('change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.not_to eql(Perm.find_by_name('grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.not_to eql(Perm.find_by_name('modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.not_to eql(Perm.find_by_name('modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.not_to eql(Perm.find_by_name('use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.not_to eql(Perm.find_by_name('change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.not_to eql(Perm.find_by_name('grant_api_to_orgs')) }
    end
  end

  describe '.grant_permissions' do
    before(:each) do
      recreate_all
    end

    subject { Perm.grant_permissions }

    context "when name is 'add_orgs'" do
      it { is_expected.not_to eql(Perm.find_by_name('add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.not_to eql(Perm.find_by_name('change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.to eql(Perm.find_by_name('grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.not_to eql(Perm.find_by_name('modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.not_to eql(Perm.find_by_name('modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.not_to eql(Perm.find_by_name('use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.not_to eql(Perm.find_by_name('change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.not_to eql(Perm.find_by_name('grant_api_to_orgs')) }
    end
  end

  describe '.modify_templates' do
    before(:each) do
      recreate_all
    end

    subject { Perm.modify_templates }

    context "when name is 'add_orgs'" do
      it { is_expected.not_to eql(Perm.find_by_name('add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.not_to eql(Perm.find_by_name('change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.not_to eql(Perm.find_by_name('grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.to eql(Perm.find_by_name('modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.not_to eql(Perm.find_by_name('modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.not_to eql(Perm.find_by_name('use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.not_to eql(Perm.find_by_name('change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.not_to eql(Perm.find_by_name('grant_api_to_orgs')) }
    end
  end

  describe '.modify_guidance' do
    before(:each) do
      recreate_all
    end

    subject { Perm.modify_guidance }

    context "when name is 'add_orgs'" do
      it { is_expected.not_to eql(Perm.find_by_name('add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.not_to eql(Perm.find_by_name('change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.not_to eql(Perm.find_by_name('grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.not_to eql(Perm.find_by_name('modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.to eql(Perm.find_by_name('modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.not_to eql(Perm.find_by_name('use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.not_to eql(Perm.find_by_name('change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.not_to eql(Perm.find_by_name('grant_api_to_orgs')) }
    end
  end

  describe '.use_api' do
    before(:each) do
      recreate_all
    end

    subject { Perm.use_api }

    context "when name is 'add_orgs'" do
      it { is_expected.not_to eql(Perm.find_by_name('add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.not_to eql(Perm.find_by_name('change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.not_to eql(Perm.find_by_name('grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.not_to eql(Perm.find_by_name('modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.not_to eql(Perm.find_by_name('modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.to eql(Perm.find_by_name('use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.not_to eql(Perm.find_by_name('change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.not_to eql(Perm.find_by_name('grant_api_to_orgs')) }
    end
  end

  describe '.change_org_details' do
    before(:each) do
      recreate_all
    end

    subject { Perm.change_org_details }

    context "when name is 'add_orgs'" do
      it { is_expected.not_to eql(Perm.find_by_name('add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.not_to eql(Perm.find_by_name('change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.not_to eql(Perm.find_by_name('grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.not_to eql(Perm.find_by_name('modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.not_to eql(Perm.find_by_name('modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.not_to eql(Perm.find_by_name('use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.to eql(Perm.find_by_name('change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.not_to eql(Perm.find_by_name('grant_api_to_orgs')) }
    end
  end

  describe '.grant_api' do
    before(:each) do
      recreate_all
    end

    subject { Perm.grant_api }

    context "when name is 'add_orgs'" do
      it { is_expected.not_to eql(Perm.find_by_name('add_organisations')) }
    end

    context "when name is 'change_affiliation'" do
      it { is_expected.not_to eql(Perm.find_by_name('change_org_affiliation')) }
    end

    context "when name is 'grant_permissions'" do
      it { is_expected.not_to eql(Perm.find_by_name('grant_permissions')) }
    end

    context "when name is 'modify_templates'" do
      it { is_expected.not_to eql(Perm.find_by_name('modify_templates')) }
    end

    context "when name is 'modify_guidance'" do
      it { is_expected.not_to eql(Perm.find_by_name('modify_guidance')) }
    end

    context "when name is 'use_api'" do
      it { is_expected.not_to eql(Perm.find_by_name('use_api')) }
    end

    context "when name is 'change_org_details'" do
      it { is_expected.not_to eql(Perm.find_by_name('change_org_details')) }
    end

    context "when name is 'grant_api'" do
      it { is_expected.to eql(Perm.find_by_name('grant_api_to_orgs')) }
    end
  end
end
