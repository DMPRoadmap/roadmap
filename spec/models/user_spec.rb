# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:email) }

    it 'should validate that email addres is unqique' do
      subject.email = 'text-email@example.com'
      is_expected.to validate_uniqueness_of(:email)
        .case_insensitive
        .with_message('has already been taken')
    end

    it {
      is_expected.to allow_values('one@example.com', 'foo-bar@ed.ac.uk')
        .for(:email)
    }

    it {
      is_expected.not_to allow_values('example.com', 'foo bar@ed.ac.uk')
        .for(:email)
    }

    it { is_expected.to allow_values(true, false).for(:active) }

    it { is_expected.not_to allow_value(nil).for(:active) }

    it { is_expected.to validate_presence_of(:firstname) }

    it { is_expected.to validate_presence_of(:surname) }

    it { is_expected.to validate_presence_of(:org) }
  end

  context 'associations' do
    it { is_expected.to have_and_belong_to_many(:perms) }

    it { is_expected.to belong_to(:language) }

    it { is_expected.to belong_to(:org) }

    it { is_expected.to have_one(:pref) }

    it { is_expected.to have_many(:answers) }

    it { is_expected.to have_many(:notes) }

    it { is_expected.to have_many(:exported_plans) }

    it { is_expected.to have_many(:roles).dependent(:destroy) }

    it { is_expected.to have_many(:plans).through(:roles) }

    it { should have_many(:identifiers) }

    it {
      is_expected.to have_and_belong_to_many(:notifications).dependent(:destroy)
    }

    it {
      is_expected.to have_and_belong_to_many(:notifications)
        .join_table('notification_acknowledgements')
    }
  end

  describe '#active_for_authentication?' do
    let!(:user) { build(:user) }

    subject { user.active_for_authentication? }

    context 'when user is active' do
      before do
        user.active = true
      end

      it { is_expected.to eql(true) }
    end

    context 'when user is not active' do
      before do
        user.active = false
      end

      it { is_expected.to eql(false) }
    end
  end

  describe '#save' do
    context 'when org has changed and can change org' do
      let!(:user) do
        create(:user, org: create(:org), api_token: 'barfoo')
      end

      before do
        user.perms << create(:perm, :change_org_affiliation)
        user.perms << create(:perm, :use_api)
        user.perms << create(:perm, :modify_guidance)
        user.perms << create(:perm, :modify_templates)
        user.perms << create(:perm, :change_org_affiliation)
        user.perms << create(:perm, :add_organisations)
        @new_org = create(:org)
        user.update(org: @new_org)
        user.reload
      end

      it 'updates the org' do
        expect(user.org).to eql(@new_org)
      end

      it "doesn't destroy user roles" do
        expect(user.perms.count).to eql(6)
      end

      it "doesn't reset api_token" do
        expect(user.api_token).to eql('barfoo')
      end
    end

    context 'when org has changed and can not change org' do
      let!(:user) do
        @org = create(:org, managed: true)
        create(:user, org: @org, api_token: 'barfoo',
                      perms: [
                        create(:perm, :use_api),
                        create(:perm, :modify_guidance),
                        create(:perm, :modify_templates)
                      ])
      end

      before do
        @new_org = create(:org)
        user.update(org: @new_org)
        user.reload
      end

      it 'does not change the org' do
        expect(user.org).to eql(@new_org)
      end

      it 'destroys user perms' do
        expect(user.perms.count).to eql(0)
      end

      it 'resets api_token to be nil' do
        expect(user.api_token).to be_nil
      end
    end
  end

  describe '#locale' do
    let!(:user) { build(:user) }

    subject { user.locale }

    context 'when user language present' do
      let(:language) { create(:language, abbreviation: 'usr-mdl') }

      before do
        user.update(language: language)
      end

      it { is_expected.to eql(language.abbreviation) }
    end

    context 'when user language and org absent' do
      before do
        user.language = nil
        user.org = nil
      end

      it { is_expected.to be_nil }
    end

    context 'when user language absent and org present' do
      before do
        user.language = nil
        @locale = user.org.locale
      end

      it { is_expected.to eql(@locale) }
    end
  end

  describe '#name' do
    let!(:user) { build(:user) }

    subject { user.name }

    context "when user firstname and surname not blank and
               use_email set to false" do
      subject { user.name(false) }

      before do
        @name = "#{user.firstname} #{user.surname}".strip
      end

      it { is_expected.to eql(@name) }
    end

    context "when user firstname is blank and surname is not blank and
               use_email set to false" do
      subject { user.name(false) }

      before do
        user.firstname = ''
        @name = user.surname.to_s.strip
      end

      it { is_expected.to eql(@name) }
    end

    context "when user firstname is blank and surname is not blank and
               use_email set to false" do
      subject { user.name(false) }

      before do
        user.surname = ''
        @name = user.firstname.to_s.strip
      end

      it { is_expected.to eql(@name) }
    end

    context "when user firstname is blank and surname is not blank
               use_email set to true (by default)" do
      before do
        user.surname = ''
        @email = user.email
      end

      it { is_expected.to eql(@email) }
    end

    context "when user firstname is not blank and surname is blank
               use_email set to true (by default)" do
      before do
        user.firstname = ''
        @email = user.email
      end

      it { is_expected.to eql(@email) }
    end

    context "when user firstname is not blank and surname is blank
               use_email set to true (by default)" do
      before do
        user.firstname = ''
        @email = user.email
      end

      it { is_expected.to eql(@email) }
    end
  end

  describe '#identifier_for' do
    let!(:user) { create(:user) }
    let!(:scheme) { create(:identifier_scheme) }

    subject { user.identifier_for(scheme.name) }

    context 'when user has an identifier present' do
      let!(:identifier) do
        create(:identifier, :for_user, identifier_scheme: scheme,
                                       identifiable: user)
      end

      it { is_expected.to eql(identifier) }
    end

    context 'when user has no identifier' do
      it { is_expected.not_to eql('') }
    end
  end

  describe '#can_super_admin?' do
    subject { user.can_super_admin? }

    context "when user includes Perm with name 'add_organisations'" do
      let!(:perms) { create_list(:perm, 1, name: 'add_organisations') }

      let!(:user) { create(:user, perms: perms) }

      it { is_expected.to eq(true) }
    end

    context "when user includes Perm with name 'grant_api_to_orgs'" do
      let!(:perms) { create_list(:perm, 1, name: 'grant_api_to_orgs') }

      let!(:user) { create(:user, perms: perms) }

      it { is_expected.to eq(true) }
    end

    context "when user includes Perm with name 'change_org_affiliation'" do
      let!(:perms) { create_list(:perm, 1, name: 'change_org_affiliation') }

      let!(:user) { create(:user, perms: perms) }

      it { is_expected.to eq(true) }
    end
  end

  describe '#can_org_admin?' do
    subject { user.can_org_admin? }

    context "when user includes Perm with name 'grant_permissions'" do
      let!(:perms) { create_list(:perm, 1, name: 'grant_permissions') }
      let!(:user) { create(:user, perms: perms) }

      it { is_expected.to eq(true) }
    end

    context "when user includes Perm with name 'modify_guidance'" do
      let!(:perms) { create_list(:perm, 1, name: 'modify_guidance') }
      let!(:user) { create(:user, perms: perms) }

      it { is_expected.to eq(true) }
    end

    context "when user includes Perm with name 'modify_templates'" do
      let!(:perms) { create_list(:perm, 1, name: 'modify_templates') }
      let!(:user) { create(:user, perms: perms) }

      it { is_expected.to eq(true) }
    end

    context "when user includes Perm with name 'change_org_details'" do
      let!(:perms) { create_list(:perm, 1, name: 'change_org_details') }
      let!(:user) { create(:user, perms: perms) }

      it { is_expected.to eq(true) }
    end
  end

  describe '#can_add_orgs?' do
    let!(:perms) { create_list(:perm, 1, name: 'add_organisations') }

    let!(:user) { create(:user, perms: perms) }

    subject { user.can_add_orgs? }

    it { is_expected.to eq(true) }
  end

  describe '#can_change_org?' do
    let!(:perms) { create_list(:perm, 1, name: 'change_org_affiliation') }

    let!(:user) { create(:user, perms: perms) }

    subject { user.can_change_org? }

    it { is_expected.to eq(true) }
  end

  describe '#can_grant_permissions?' do
    let!(:perms) { create_list(:perm, 1, name: 'grant_permissions') }

    let!(:user) { create(:user, perms: perms) }

    subject { user.can_grant_permissions? }

    it { is_expected.to eq(true) }
  end

  describe '#can_modify_templates?' do
    let!(:perms) { create_list(:perm, 1, name: 'modify_templates') }

    let!(:user) { create(:user, perms: perms) }

    subject { user.can_modify_templates? }

    it { is_expected.to eq(true) }
  end

  describe '#can_modify_guidance?' do
    let!(:perms) { create_list(:perm, 1, name: 'modify_guidance') }

    let!(:user) { create(:user, perms: perms) }

    subject { user.can_modify_guidance? }

    it { is_expected.to eq(true) }
  end

  describe '#can_use_api?' do
    let!(:perms) { create_list(:perm, 1, name: 'use_api') }

    let!(:user) { create(:user, perms: perms) }

    subject { user.can_use_api? }

    it { is_expected.to eq(true) }
  end

  describe '#can_modify_org_details?' do
    let!(:perms) { create_list(:perm, 1, name: 'change_org_details') }

    let!(:user) { create(:user, perms: perms) }

    subject { user.can_modify_org_details? }

    it { is_expected.to eq(true) }
  end

  describe '#can_grant_api_to_orgs?' do
    let!(:perms) { create_list(:perm, 1, name: 'grant_api_to_orgs') }

    let!(:user) { create(:user, perms: perms) }

    subject { user.can_grant_api_to_orgs? }

    it { is_expected.to eq(true) }
  end

  describe '#remove_token!' do
    subject { user.remove_token! }

    context 'when user is not a new record and api_token is not blank' do
      let!(:user) { create(:user, api_token: 'an token string') }

      it { expect { subject }.to change { user.api_token }.to(nil) }
    end

    context 'when user is not a new record and api_token is nil' do
      let!(:user) { create(:user, api_token: nil) }

      it { expect { subject }.not_to change { user.api_token } }
    end

    context 'when user is not a new record and api_token is an empty string' do
      let!(:user) { create(:user, api_token: '') }

      it { expect { subject }.to change { user.api_token }.to(nil) }
    end

    context 'when user is a new record' do
      let!(:user) { build(:user, api_token: 'an token string') }

      it { expect { subject }.not_to change { user.api_token } }
    end
  end

  describe '#keep_or_generate_token!' do
    subject { user.keep_or_generate_token! }

    context 'when user is not a new record and api_token is an empty string' do
      let!(:user) { create(:user, api_token: '') }

      it { expect { subject }.to change { user.api_token } }
    end

    context 'when user is not a new record and api_token is nil' do
      let!(:user) { create(:user, api_token: nil) }

      it { expect { subject }.to change { user.api_token } }
    end

    context 'when user is a new record and api_token is an empty string' do
      let!(:user) { build(:user, api_token: '') }

      it { expect { subject }.not_to change { user.api_token } }
    end
  end

  # Test creationg a User from an omniauth callback like Shibboleth
  describe '.from_omniauth' do
    let!(:user) { create(:user) }
    let!(:auth) do
      OpenStruct.new(provider: Faker::Lorem.unique.word, uid: Faker::Lorem.word)
    end
    let!(:scheme) { create(:identifier_scheme, name: auth[:provider], identifier_prefix: nil) }

    subject { User.from_omniauth(auth) }

    context 'when User has Identifier, with different ID' do
      let!(:identifier) do
        create(:identifier, :for_user, identifiable: user,
                                       identifier_scheme: scheme,
                                       value: Faker::Movies::StarWars.character)
      end

      it { is_expected.to be_nil }
    end

    context 'when user Identifier and auth Provider are the same string' do
      let!(:identifier) do
        create(:identifier, :for_user, identifiable: user,
                                       identifier_scheme: scheme,
                                       value: auth[:uid])
      end

      it { is_expected.to eql(user) }
    end
  end

  describe '#get_preferences' do
    let!(:user) { create(:user) }

    let!(:key) { :email }

    subject { user.get_preferences(key) }

    context "when the User doesn't have thier own Pref" do
      it 'returns the default value' do
        Pref.expects(:default_settings)
            .returns(email: { foo: { 'bar' => 'baz' } })
        expect(subject).to eql({ foo: { 'bar' => 'baz' } })
      end
    end

    context 'when the User has thier own Pref' do
      before do
        create(:pref, user: user,
                      settings: { email: { foo: { bar: 'bam' } } })
      end

      it "returns the User's value" do
        Pref.expects(:default_settings)
            .returns(email: { foo: { bar: 'baz' } })
        expect(subject).to eql({ foo: { bar: 'bam' } })
      end
    end

    context "when the User's own Pref doesn't contain a new default" do
      before do
        create(:pref, user: user,
                      settings: { email: { foo: { bar: 'bam' } } })
      end

      it 'includes the default' do
        Pref.expects(:default_settings)
            .returns(email: { default: { val: true }, foo: { bar: 'baz' } })
        expect(subject).to eql({ default: { val: true }, foo: { bar: 'bam' } })
      end
    end
  end

  describe '.where_case_insensitive' do
    before do
      @user = create(:user, firstname: 'Test')
    end

    subject { User.where_case_insensitive(:firstname, value) }

    context 'when search value is capitalized' do
      let!(:value) { 'TEST' }

      it { is_expected.to include(@user) }
    end

    context 'when search value matches case' do
      let!(:value) { 'Test' }

      it { is_expected.to include(@user) }
    end

    context 'when search value is lowercase' do
      let!(:value) { 'test' }

      it { is_expected.to include(@user) }
    end
  end

  describe '#acknowledge' do
    let!(:user) { create(:user) }

    subject { user.acknowledge(notification) }

    context 'when notification is dismissable' do
      let!(:notification) { create(:notification, :dismissable) }

      it "adds the Notification to the User's notifications" do
        subject
        expect(user.notifications).to include(notification)
      end
    end

    context 'when notification is not dismissable' do
      let!(:notification) { create(:notification) }

      it "doesn't add the Notification to the User's notifications" do
        subject
        expect(user.notifications).not_to include(notification)
      end
    end
  end
end
