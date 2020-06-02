# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::PlanPolicy, type: :policy do
  context "authorize checks" do
    describe "index?" do
      context "Client as a User" do
        subject { described_class.new(create(:user), Plan) }

        it "has access" do
          is_expected.to permit_action(:index)
        end
      end
      context "Client as a OrgAdmin" do
        subject { described_class.new(create(:user, :org_admin), Plan) }

        it "has access" do
          is_expected.to permit_action(:index)
        end
      end
      context "Client as an ApiClient" do
        subject { described_class.new(create(:api_client), Plan) }

        it "has access" do
          is_expected.to permit_action(:index)
        end
      end
      context "Client is nil" do
        subject { described_class.new(nil, Plan) }

        it "does not have access" do
          is_expected.not_to permit_action(:index)
        end
      end
    end

    describe "show?" do
      context "Client as a User" do
        subject { described_class.new(create(:user), Plan) }

        it "has access" do
          is_expected.to permit_action(:show)
        end
      end
      context "Client as an OrgAdmin" do
        subject { described_class.new(create(:user, :org_admin), Plan) }

        it "has access if Plan is owned by the User's Org regardless of visibility" do
          is_expected.to permit_action(:show)
        end
      end
      context "Client as an ApiClient" do
        subject { described_class.new(create(:api_client), Plan) }

        it "has access" do
          is_expected.to permit_action(:show)
        end
      end
      context "Client is nil" do
        subject { described_class.new(nil, Plan) }

        it "does not have access" do
          is_expected.not_to permit_action(:show)
        end
      end
    end
  end

  describe "policy_scope" do
    context "Client is an ApiClient" do
      before(:each) do
        @client = create(:api_client)
        @scope = described_class::Scope.new(@client, Plan)
      end

      it "can access Plan if :publicly_visible" do
        plan = create(:plan, :publicly_visible, org: create(:org))
        expect(@scope.resolve.include?(plan)).to eql(true)
      end
      it "can access Plan if owned by the ApiClient" do
        plan = create(:plan, :privately_visible)
        @client.plans << plan
        @client.save
        expect(@scope.resolve.include?(plan)).to eql(true)
      end
      it "can NOT access Plan if not owned by the ApiClient" do
        plan = create(:plan, :privately_visible)
        expect(@scope.resolve.include?(plan)).to eql(false)
      end
    end

    context "Client is a User" do
      before(:each) do
        @org = create(:org)
        @seed_plan = create(:plan, :creator, :privately_visible, org: @org)
        @client = @seed_plan.owner

        @scope = described_class::Scope.new(@client, Plan)
      end

      it "can access Plan if :publicly_visible" do
        plan = create(:plan, :creator, :publicly_visible, org: create(:org))
        expect(@scope.resolve.include?(plan)).to eql(true)
      end
      it "can access Plan if owned by the User" do
        expect(@scope.resolve.include?(@seed_plan)).to eql(true)
      end
      it "can acces Plan if owned by the User's Org and :organisationally_visible" do
        plan = create(:plan, :creator, :organisationally_visible, org: @org)
        expect(@scope.resolve.include?(plan)).to eql(true)
      end
      it "can NOT access Plan that belongs to another Org" do
        plan = create(:plan, :creator, :privately_visible, org: create(:org))
        expect(@scope.resolve.include?(plan)).to eql(false)
      end

      context "Plan that is owned by user Org but not :organisationally_visible" do
        it "can NOT access Plan if user is not an OrgAdmin" do
          @client.stubs(:can_org_admin?).returns(false)
          plan = create(:plan, :creator, :privately_visible, org: @org)
          expect(@scope.resolve.include?(plan)).to eql(false)
        end
        it "can access Plan if user is an OrgAdmin" do
          @client.stubs(:can_org_admin?).returns(true)
          plan = create(:plan, :creator, :privately_visible, org: @org)
          expect(@scope.resolve.include?(plan)).to eql(true)
        end
      end

    end
  end
end
