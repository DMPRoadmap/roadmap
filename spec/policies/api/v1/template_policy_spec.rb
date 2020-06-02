# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::TemplatePolicy, type: :policy do
  context "authorize checks" do
    describe "index?" do
      context "Client as a User" do
        subject { described_class.new(create(:user), Template) }

        it "has access" do
          is_expected.to permit_action(:index)
        end
      end
      context "Client as a OrgAdmin" do
        subject { described_class.new(create(:user, :org_admin), Template) }

        it "has access" do
          is_expected.to permit_action(:index)
        end
      end
      context "Client as an ApiClient" do
        subject { described_class.new(create(:api_client), Template) }

        it "has access" do
          is_expected.to permit_action(:index)
        end
      end
      context "Client is nil" do
        subject { described_class.new(nil, Template) }

        it "does not have access" do
          is_expected.not_to permit_action(:index)
        end
      end
    end
  end

  describe "policy_scope" do
    before(:each) do
      @template = create(:template, :publicly_visible, published: true)
    end

    context "Client is an ApiClient" do
      before(:each) do
        @client = create(:api_client)
        @scope = described_class::Scope.new(@client, Template)
      end

      it "can access Template if :published and :publicly_visible" do
        expect(@scope.resolve.include?(@template)).to eql(true)
      end
      it "can NOT access Template that is not :published" do
        template = create(:template, :publicly_visible, published: false)
        expect(@scope.resolve.include?(template)).to eql(false)
      end
      it "can NOT access Customization" do
        template = create(:template, :publicly_visible, published: true,
                                                        customization_of: @template.id)
        expect(@scope.resolve.include?(template)).to eql(false)
      end
      it "can NOT access Template that is not :publicly_visible" do
        template = create(:template, :organisationally_visible, published: true)
        expect(@scope.resolve.include?(template)).to eql(false)
      end
    end

    context "Client is a User" do
      before(:each) do
        @org = create(:org)
        @client = create(:user, org: @org)
        @scope = described_class::Scope.new(@client, Template)
      end

      it "can access Template if :published and :publicly_visible" do
        expect(@scope.resolve.include?(@template)).to eql(true)
      end
      it "can NOT access Template that is not :published" do
        template = create(:template, :publicly_visible, published: false)
        expect(@scope.resolve.include?(template)).to eql(false)
      end
      it "can access Template if owned by the Org" do
        template = create(:template, :organisationally_visible, org: @org, published: true)
        expect(@scope.resolve.include?(template)).to eql(true)
      end
      it "can NOT access Template that belongs to another Org" do
        template = create(:template, :organisationally_visible, org: create(:org),
                                                                published: true)
        expect(@scope.resolve.include?(template)).to eql(false)
      end
      it "can access Customization if owned by the Org" do
        template = create(:template, :organisationally_visible, org: @org, published: true,
                                                                customization_of: @template.id)
        expect(@scope.resolve.include?(template)).to eql(true)
      end
      it "can NOT access Customization that belongs to another Org" do
        template = create(:template, :organisationally_visible, org: create(:org), published: true,
                                                                customization_of: @template.id)
        expect(@scope.resolve.include?(template)).to eql(false)
      end
    end
  end
end
