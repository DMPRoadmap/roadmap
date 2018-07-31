require 'rails_helper'

RSpec.describe User, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of(:email) }

    it "should validate that email addres is unqique" do
      subject.email = "text-email@example.com"
      is_expected.to validate_uniqueness_of(:email)
                       .case_insensitive
                       .with_message("has already been taken")
    end

    it { is_expected.to allow_values("one@example.com", "foo-bar@ed.ac.uk")
                          .for(:email) }

    it { is_expected.not_to allow_values("example.com", "foo bar@ed.ac.uk")
                              .for(:email) }

    it { is_expected.to allow_values(true, false).for(:active) }

    it { is_expected.not_to allow_value(nil).for(:active) }
  end
  
  
  
  context "associations" do
    
    it { should have_and_belong_to_many(:perms)}
    
    it { should belong_to(:language) }
    
    it { should belong_to(:org) }
    
    it { should have_one(:pref) }
    
    it { should have_many(:answers) }
    
    it { should have_many(:notes) }
    
    it { should have_many(:exported_plans) }
    
    it { should have_many(:roles).dependent(:destroy) }
    
    it { should have_many(:plans).through(:roles) }
    
    it { should have_many(:user_identifiers) }
    
    it { should have_many(:identifier_schemes).through(:user_identifiers) }

    it { should have_and_belong_to_many(:notifications).dependent(:destroy) }
    
    it { should have_and_belong_to_many(:notifications).join_table("notification_acknowledgements") }
  end
  
  context "#active_for_authentication?" do
    
    let!(:user) { build(:user)}
    
    subject { user.active_for_authentication? }
    
    context "when user is active" do
      before do
        user.active = true
      end
      
      it { is_expected.to eql(true) }
      
    end
    
    context "when user is not active" do
      before do
        user.active = false
      end
      
      it { is_expected.to eql(false) }
      
    end
  end
  
  context "#get_locale" do
    
    let!(:user) { build(:user) }
    
    subject { user.get_locale }
    
    context "when user language present" do
      
      before do
        @abbreviation = user.language.abbreviation
      end

      it { is_expected.to eql(@abbreviation) }
      
    end
    
    context "when user language and org absent" do
      
      before do
        user.language = nil
        user.org = nil
      end
      
      it { is_expected.to be_nil }
      
    end
    
    context "when user language absent and org present" do
      
      before do
        user.language = nil
        @locale = user.org.get_locale
      end
      
      it { is_expected.to eql(@locale) }
      
    end
  end
  
  context "#name" do
    
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
        user.firstname = ""
        @name = "#{user.surname}".strip
      end
      
      it { is_expected.to eql(@name) }

    end
    
    context "when user firstname is blank and surname is not blank and 
               use_email set to false" do
               
      subject { user.name(false) }
      
      before do
        user.surname = ""
        @name = "#{user.firstname}".strip
      end
      
      it { is_expected.to eql(@name) }

    end
    
    context "when user firstname is blank and surname is not blank
               use_email set to true (by default)" do

      before do
        user.surname = ""
        @email = user.email
      end
               
      it { is_expected.to eql(@email) }

    end
    
    context "when user firstname is not blank and surname is blank
               use_email set to true (by default)" do
      before do
        user.firstname = ""
        @email = user.email
      end
               
      it { is_expected.to eql(@email) }

    end
    
    context "when user firstname is not blank and surname is blank
               use_email set to true (by default)" do
      before do
        user.firstname = ""
        @email = user.email
      end
               
      it { is_expected.to eql(@email) }

    end
  end
  
  context "#active_plans" do
    let!(:user) { create(:user) }
    let!(:plan) { create(:plan) }
    
     subject { user.active_plans }
    
    context "user has :reviewer role only and role active" do
      
      let!(:role) { create(:role, :reviewer, user: user, plan: plan, active: true) }
      
      it { is_expected.not_to include(plan) }
      
    end
     
    context "user has :creator role only and role active" do
      
      let!(:role) { create(:role, :creator, user: user, plan: plan, active: true) }
      
      it { is_expected.to include(plan) }
      
    end
    
    context "user has :administrator role only and role active" do
      
      let!(:role) { create(:role, :administrator, user: user, plan: plan, active: true) }
      
      it { is_expected.to include(plan) }
      
    end
    
    context "user has :editor role only and role active" do
      
      let!(:role) { create(:role, :editor, user: user, plan: plan, active: true) }
      
      it { is_expected.to include(plan) }
      
    end
    
    context "user has :commenter role only and role active" do
      
      let!(:role) { create(:role, :commenter, user: user, plan: plan, active: true) }
      
      it { is_expected.to include(plan) }
      
    end
    
    context "user has :creator, :administrator, :editor, :commenter roles and 
             role active" do
      
      let!(:role) { create(:role, 
                           :creator, 
                           :administrator, 
                           :editor, 
                           :commenter, 
                           user: user, 
                           plan: plan, 
                           active: true) }
      
      it { is_expected.to include(plan) }
      
    end
    
    context "user has :creator, :administrator, :editor, :commenter roles and 
             role not active" do
      
      let!(:role) { create(:role, 
                           :creator, 
                           :administrator, 
                           :editor, 
                           :commenter, 
                           user: user, 
                           plan: plan, 
                           active: false) }
      
      it { is_expected.not_to include(plan) }
      
    end
    
    context "user has :reviewer and other roles and role active" do
      
      let!(:role) { create(:role, 
                           :reviewer, 
                           :creator, 
                           :administrator, 
                           :editor, 
                           :commenter, 
                           user: user, 
                           plan: plan, 
                           active: true) }
      
      it { is_expected.not_to include(plan) }
      
    end
  end
  
  describe "#identifier_for" do
    let!(:user) { create(:user) }
    let!(:identifier_scheme) { create(:identifier_scheme) }
  
    
    subject { user.identifier_for(identifier_scheme) }
    
    context "when user has an user_identifier of scheme identifier_scheme present" do
      
      let!(:user_identifier) { create(:user_identifier, identifier_scheme: identifier_scheme, user: user) }
      
      it { is_expected.to eql(user_identifier) }
      
    end
    
    context "when user has no user_identifier of scheme identifier_scheme" do
      
      let!(:user_identifier) { create(:user_identifier, user: user) }
      
      it { is_expected.not_to eql(user_identifier) }
      
    end
  end
  
  describe "#can_super_admin?" do
    
    subject { user.can_super_admin? }
    
    context "when user includes Perm with name 'add_organisations'" do
      
      let!(:perms) { create_list(:perm, 1, name: "add_organisations") }
      let!(:user) { create(:user, perms: perms) }
      
      it { is_expected.to eq(true) }

    end
   
    context "when user includes Perm with name 'grant_api_to_orgs'" do
     
      let!(:perms) { create_list(:perm, 1, name: "grant_api_to_orgs") }
      let!(:user) { create(:user, perms: perms) }
     
      it { is_expected.to eq(true) }

    end
   
   context "when user includes Perm with name 'change_org_affiliation'" do
     
      let!(:perms) { create_list(:perm, 1, name: "change_org_affiliation") }
      let!(:user) { create(:user, perms: perms) }
     
      it { is_expected.to eq(true) }

   end
   
    # TBD: Null cases  
  end
  
  describe "#can_org_admin?" do
    
    subject { user.can_org_admin? }

    context "when user includes Perm with name 'grant_permissions'" do
      
      let!(:perms) { create_list(:perm, 1, name: "grant_permissions") }
      let!(:user) { create(:user, perms: perms) }
      
      it { is_expected.to eq(true) }

    end
   
    context "when user includes Perm with name 'modify_guidance'" do
     
      let!(:perms) { create_list(:perm, 1, name: "modify_guidance") }
      let!(:user) { create(:user, perms: perms) }
     
      it { is_expected.to eq(true) }

    end
   
   context "when user includes Perm with name 'modify_templates'" do
     
      let!(:perms) { create_list(:perm, 1, name: "modify_templates") }
      let!(:user) { create(:user, perms: perms) }
     
      it { is_expected.to eq(true) }

   end
   
   context "when user includes Perm with name 'change_org_details'" do
     
      let!(:perms) { create_list(:perm, 1, name: "change_org_details") }
      let!(:user) { create(:user, perms: perms) }
     
      it { is_expected.to eq(true) }

   end
   
    # TBD: Null cases  
    
  end
  
  describe "#can_add_orgs?" do
    
    let!(:perms) { create_list(:perm, 1, name: "add_organisations") }
    let!(:user) { create(:user, perms: perms) }
    
    subject { user.can_add_orgs? }
    
    it { is_expected.to eq(true) }
    
  end
  
  describe "#can_change_org?" do
    
    let!(:perms) { create_list(:perm, 1, name: "change_org_affiliation") }
    let!(:user) { create(:user, perms: perms) }
    
    subject { user.can_change_org? }
    
    it { is_expected.to eq(true) }

  end
  
  describe "#can_grant_permissions?" do
    
    let!(:perms) { create_list(:perm, 1, name: "grant_permissions") }
    let!(:user) { create(:user, perms: perms) }
    
    subject { user.can_grant_permissions? }
    
    it { is_expected.to eq(true) }

  end
  
  describe "#can_modify_templates?" do
    
    let!(:perms) { create_list(:perm, 1, name: "modify_templates") }
    let!(:user) { create(:user, perms: perms) }
    
    subject { user.can_modify_templates? }
    
    it { is_expected.to eq(true) }
    
  end
  
  describe "#can_modify_guidance?" do
    
    let!(:perms) { create_list(:perm, 1, name: "modify_guidance") }
    let!(:user) { create(:user, perms: perms) }
    
    subject { user.can_modify_guidance? }
    
    it { is_expected.to eq(true) }
     
  end
  
  describe "#can_use_api?" do
    
    let!(:perms) { create_list(:perm, 1, name: "use_api") }
    let!(:user) { create(:user, perms: perms) }
    
    subject { user.can_use_api? }
    
    it { is_expected.to eq(true) }

  end
  
  describe "#can_modify_org_details?" do
    
    let!(:perms) { create_list(:perm, 1, name: "change_org_details") }
    let!(:user) { create(:user, perms: perms) }
    
    subject { user.can_modify_org_details? }
    
    it { is_expected.to eq(true) }
     
  end
  
  describe "#can_grant_api_to_orgs?" do
    
    let!(:perms) { create_list(:perm, 1, name: "grant_api_to_orgs") }
    let!(:user) { create(:user, perms: perms) }
    
    subject { user.can_grant_api_to_orgs? }
    
    it { is_expected.to eq(true) }
    
  end
  
  describe "#remove_token!" do
    
    subject { user.remove_token! }
    
    context "when user is not a new record and api_token is not blank" do
      
      let!(:user) { create(:user, api_token: "an token string") }
      
      it { expect { subject }.to change{ user.api_token }.to ("") }
      
    end
    
    context "when user is not a new record and api_token is nil" do
      
      let!(:user) { create(:user, api_token: nil) }
      
      it { expect { subject }.not_to change{ user.api_token } }
      
    end
    
    context "when user is not a new record and api_token is an empty string" do
      
      let!(:user) { create(:user, api_token: "") }
      
      it { expect { subject }.not_to change{ user.api_token } }
      
    end
    
    context "when user is a new record" do
      
      let!(:user) { build(:user, api_token: "an token string") }
      
      it { expect { subject }.not_to change{ user.api_token } }
      
    end
  end
  
  describe "#keep_or_generate_token!" do
   
    subject { user.keep_or_generate_token! }
    
    context "when user is not a new record and api_token is an empty string" do
      
      let!(:user) { create(:user, api_token: "") }
      
      it { expect { subject }.to change{ user.api_token } }
      
    end
    
    context "when user is not a new record and api_token is nil" do
      
      let!(:user) { create(:user, api_token: "") }
      
      it { expect { subject }.to change{ user.api_token } }
      
    end
    
    context "when user is a new record and api_token is an empty string" do
      
      let!(:user) { build(:user, api_token: "") }
      
      it { expect { subject }.not_to change{ user.new_record? } }
      
    end
  end

######  TBD  
  describe ".from_omniauth(auth)" do
  
    let!(:user) { create(:user) }
    let!(:auth) { stub(provider: "auth-provider", uid: "auth_uid") }
    subject { User.from_omniauth(auth) }
    
  
    context "when User_Identifier and auth Provider are different strings" do
    
      before do
        @identifier_scheme_1 = create(:identifier_scheme, name: "auth_uid")
        create(:user_identifier, user: user, identifier_scheme: @identifier_scheme, identifier: "another-auth-uid")
      end

      it { expect { subject }.to raise_error(Exception) }
    
    end
  
    context "when user Identifier and auth Provider are the same string" do
    
      before do
        @identifier_scheme = create(:identifier_scheme, name: "auth_uid")
        create(:user_identifier, user: user, identifier_scheme: @identifier_scheme,  identifier: "auth-uid")
      end
    
      it { is_expected.to eq(user) }
    
    end
    
  end
  
  describe "#get_preferences(key)" do
    
    subject { user.get_preferences(key) }
    
    pending "To be implemented" do
      
      context "Implement" do
        
      end
    end
  end
  
  describe "#deliver_invitation(options = {})" do
    
    pending "To be implemented" do
      context "Implement" do
        
      end
    end 
    
  end
  
  describe ".where_case_insensitive(@field, @value)" do
  
    let!(:user) { create(:user, firstname: "Test") }
  
    subject { User.where_case_insensitive(@field, @value) }
  
    context "when search value is capitalized" do
    
      before do
        @field = "firstname"
        @value = "TEST"
      end
      
      it { expect(subject).to eq(user) }
    
    end
  
  end
  
  describe "#acknowledge(notification)" do
    
    let!(:user) { create(:user) }
    subject { user.acknowledge(notification) }
    
    context "when notification is dismissable" do
    
      let!(:notification){ create(:notification, :dismissable) }
    
    
      it { expect { subject; user.reload.notifications }.to change{ user.notifications }.to include(notification) }
    
    end
    
    context "when notification is not dismissable" do
    
      let!(:notification){ create(:notification) }
    
      it { expect { subject; user.reload.notifications }.not_to change{ user.notifications } }
    
    end
  end

  
end
