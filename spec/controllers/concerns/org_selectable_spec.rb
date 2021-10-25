# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrgSelectable do

  before(:each) do
    class StubController < ApplicationController

      include OrgSelectable

    end

    @controller = StubController.new

    OrgSelection::HashToOrgService.stubs(:to_org).returns(build(:org))
    OrgSelection::HashToOrgService.stubs(:to_identifiers)
                                  .returns([build(:identifier)])

    org_id = { id: Faker::Number.number, name: Faker::Company.name }.to_json
    @params = ActionController::Parameters.new({
                                                 other_param: Faker::Company.name,
                                                 org_id: org_id,
                                                 org_name: Faker::Company.name,
                                                 org_sources: [Faker::Company.name],
                                                 org_crosswalk: [{ id: Faker::Number.number }]
                                               })
  end

  after(:each) do
    Object.send :remove_const, :StubController
  end

  context "private methods" do

    describe "#org_from_params(params:)" do
      it "returns nil if params[:org_id] is not present" do
        expect(@controller.send(:org_from_params, params_in: {})).to eql(nil)
      end
      it "returns nil if the params[:org_id] could not be converted" do
        @controller.stubs(:org_hash_from_params).returns({})
        expect(@controller.send(:org_from_params, params_in: {})).to eql(nil)
      end
      it "returns an Org" do
        rslt = @controller.send(:org_from_params, params_in: @params)
        expect(rslt.is_a?(Org)).to eql(true)
      end
    end

    describe "#identifiers_from_params(params:)" do
      it "returns an empty array if params[:org_id] is not present" do
        rslt = @controller.send(:identifiers_from_params, params_in: {})
        expect(rslt).to eql([])
      end
      it "returns an empty array if params[:org_id] could not be converted" do
        @controller.stubs(:org_hash_from_params).returns({})
        rslt = @controller.send(:identifiers_from_params, params_in: {})
        expect(rslt).to eql([])
      end
      it "returns an Array of identifiers" do
        rslt = @controller.send(:identifiers_from_params, params_in: @params)
        expect(rslt.is_a?(Array)).to eql(true)
        expect(rslt.first.is_a?(Identifier)).to eql(true)
      end
    end

    describe "#org_hash_from_params(params:)" do
      it "returns an empty hash is there is a JSON parse error" do
        JSON.expects(:parse).raises(JSON::ParserError)
        rslt = @controller.send(:org_hash_from_params, params_in: @params)
        expect(rslt).to eql({})
      end
      it "logs JSON parse error" do
        JSON.expects(:parse).raises(JSON::ParserError)
        Rails.logger.expects(:error).at_least(2)
        @controller.send(:org_hash_from_params, params_in: @params)
      end
      it "returns the hash" do
        rslt = @controller.send(:org_hash_from_params, params_in: @params)
        expect(rslt).to eql(JSON.parse(@params[:org_id]))
      end
    end

    describe "#remove_org_selection_params(params:)" do
      before(:each) do
        @rslt = @controller.send(:remove_org_selection_params,
                                 params_in: @params)
      end
      it "removes the org_selector params" do
        expect(@rslt[:org_id].present?).to eql(false)
        expect(@rslt[:org_name].present?).to eql(false)
        expect(@rslt[:org_sources].present?).to eql(false)
        expect(@rslt[:org_crosswalk].present?).to eql(false)
      end
      it "does not remove other params" do
        expect(@rslt[:other_param].present?).to eql(true)
      end
    end

  end

end
