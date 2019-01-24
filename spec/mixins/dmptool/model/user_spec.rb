require 'rails_helper'


RSpec.describe User, type: :model do

  describe "DMPTool customizations to User model" do

    before do
      generate_shibbolized_orgs(1)
    end

    let!(:org) { Org.participating.first }

    context ".ldap_password?" do

      it "correctly determines if the user has an ldap password" do
        user = create(:user, ldap_password: "ABCD123")
        expect(user.ldap_password?).to eql(true)
      end

    end

    context ".valid_password?" do

      let(:password) { "Testing*12!" }
      let(:salt) { "saltyTst" }

      it "converts a user's LDAP password to Devise password" do
        # Create a user and then remove their Devise passwords to simulate
        # a record migrated from the old DMPTool v2 LDAP security model
        encoded = Base64.encode64(Digest::SHA1.digest(password+salt)+salt).chomp!
        user = create(:user, ldap_password: "{SSHA}"+encoded)
        user.password = ""
        user.encrypted_password = ""
        user.save(validate: false)
        expect(user.valid_password?(password)).to eql(true)
        # Make sure the old LDAP password was deleted and that the new Devise
        # password was properly converted
        user.reload
        expect(user.encrypted_password.present?).to eql(true)
        expect(user.ldap_password.present?).to eql(false)
        expect(user.valid_password?(password)).to eql(true)
      end

      it "does not change the user's password if they already have a Devise password" do
        encoded = Base64.encode64(Digest::SHA1.digest(password+salt)+salt).chomp!
        user = create(:user, ldap_password: "{SSHA}"+encoded)
        expect(user.valid_password?(password)).to eql(false)
        expect(user.ldap_password.present?).to eql(true)
        expect(user.encrypted_password.present?).to eql(true)
      end

      it "does not change the user's password if the provided password is invalid" do
        # Create a user and then remove their Devise passwords to simulate
        # a record migrated from the old DMPTool v2 LDAP security model
        encoded = Base64.encode64(Digest::SHA1.digest(password+salt)+salt).chomp!
        user = create(:user, ldap_password: "{SSHA}"+encoded)
        user.password = ""
        user.encrypted_password = ""
        user.save(validate: false)
        expect(user.valid_password?("INVALID_Passwd12")).to eql(false)
        expect(user.ldap_password.present?).to eql(true)
        expect(user.encrypted_password.present?).to eql(false)
      end

    end

  end

end