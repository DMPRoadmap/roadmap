# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegistrationsController, type: :controller do

  before(:each) do
    @org = create(:org, is_other: false)
    @user = create(:user, org: @org)
  end

  context "private methods" do

    before(:each) do
      @controller = described_class.new
    end

    describe "#params_to_org_id!(org_id:)" do

      before(:each) do
        @hash = {
          id: @org.id.to_s,
          name: Faker::Lorem.word,
          ror: Faker::Lorem.word
        }.to_json
      end

      it "returns nil if the org_id is not a string" do
        rslt = @controller.send(:params_to_org_id!, org_id: nil)
        expect(rslt).to eql(nil)
      end

      it "returns the correct org" do
        rslt = @controller.send(:params_to_org_id!, org_id: @hash)
        expect(rslt).to eql(@org.id)
      end

      it "returns nil if there is a JSON parse error with org_id" do
        Rails.logger.stubs(:error).returns(true)
        rslt = @controller.send(:params_to_org_id!, org_id: "#{@hash}7fy]")
        expect(rslt).to eql(nil)
      end

      it 'creates a new org' do
        hash = { name: Faker::Lorem.sentence }
        rslt = @controller.send(:params_to_org_id!, org_id: hash.to_json)
        expect(rslt.name).to eql(hash[:name])
        expect(rslt.id.present?).to eql(true)
      end

    end

  end

end
