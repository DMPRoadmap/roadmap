# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsageController, type: :controller do
  before(:each) do
    @date = Date.today.last_month.end_of_month
    @org = create(:org, :organisation)
    @details = { "by_template": [stat_details], "using_template": [] }
    @plan_stat = create(:stat_created_plan, date: @date, org: @org, details: @details)
    @user_stat = create(:stat_joined_user, date: @date, org: @org)

    sign_in(create(:user, :super_admin, org: @org))
  end

  describe "GET /usage (aka index)" do
    before(:each) do
      get :index
    end
    it "assigns the correct user stats (@users_per_month)" do
      expect(assigns(:users_per_month)).to eql(obj_to_hash(obj: @user_stat))
    end
    it "assigns the correct plan stats" do
      expect(assigns(:plans_per_month)).to eql(obj_to_hash(obj: @plan_stat))
    end
    it "assigns the correct total users" do
      expect(assigns(:total_org_users)).to eql(@user_stat.count)
    end
    it "assigns the correct total plans" do
      expect(assigns(:total_org_plans)).to eql(@plan_stat.count)
    end
  end

  describe "POST /usage_plans_by_template" do
    before(:each) do
      # Skipping the prior month because it was already created above
      (2..12).each do |i|
        date = Date.today.months_ago(i).end_of_month
        details = { "by_template": [stat_details] }
        create(:stat_created_plan, date: date, org: @org, details: details)
      end
      @annual = StatCreatedPlan.all.order(date: :desc)
    end
    describe "test for each date range" do
      [1, 3, 6, 9, 12].each do |months|
        context "last #{months} months" do
          before(:each) do
            @date = Date.today.months_ago(months).end_of_month.strftime("%Y-%m-%d")
            post :plans_by_template, params: { usage: { template_plans_range: @date } },
                                     format: :js
          end
          it "returns the expected data" do
            # Controller returns results in date ascending order so resort the
            # records after extracting the ones we want first
            expected = @annual[0..months - 1].sort { |a, b| a.date <=> b.date }
                                             .map { |stat| obj_to_hash(obj: stat) }
            expect(assigns(:plans_per_month)).to eql(expected.flatten)
          end
        end
      end
    end
  end

  describe "GET /usage_global_statistics" do
    before(:each) do
      get :global_statistics
    end
    it "assigns the correct csv data" do
      csvified_name = @org.name.include?(",") ? "\"#{@org.name}\"" : @org.name
      expected = "Org name,Total users,Total plans\n" \
                 "#{csvified_name},#{@user_stat.count},#{@plan_stat.count}\n"
      expect(response.content_type).to eq("text/csv")
      expect(response.body).to eql(expected)
    end
  end

  describe "GET /usage_yearly_users" do
    before(:each) do
      get :yearly_users
    end
    it "assigns the correct csv data" do
      expected = "Month,No. Users joined\n" \
                 "#{@date.strftime('%b-%y')},#{@user_stat.count}\n" \
                 "Total,#{@user_stat.count}\n"
      expect(response.content_type).to eq("text/csv")
      expect(response.body).to eql(expected)
    end
  end

  describe "GET /usage_yearly_plans" do
    before(:each) do
      get :yearly_plans
    end
    it "assigns the correct csv data" do
      expected = "Month,No. Completed Plans\n" \
                 "#{@date.strftime('%b-%y')},#{@plan_stat.count}\n" \
                 "Total,#{@plan_stat.count}\n"
      expect(response.content_type).to eq("text/csv")
      expect(response.body).to eql(expected)
    end
  end

  describe "GET /usage_all_plans_by_template" do
    before(:each) do
      get :all_plans_by_template
    end
    it "assigns the correct csv data" do
      name = @details[:by_template].first[:name]
      count = @details[:by_template].first[:count]
      expected = "Date,#{name},Count\n" \
                 "#{@date.strftime('%b %Y')},#{count},#{@plan_stat.count}\n"
      expect(response.content_type).to eq("text/csv")
      expect(response.body).to eql(expected)
    end
  end

  def obj_to_hash(obj:)
    hash = { "count": obj.count, "date": obj.date.strftime("%Y-%m-%d") }
    hash["by_template"] = obj.details.fetch("by_template", []) if obj.details.present?
    hash["using_template"] = obj.details.fetch("using_template", []) if obj.details.present?
    [hash.to_json]
  end

  def stat_details
    { "name": Faker::Lorem.unique.sentence, "count": Faker::Number.number(digits: 2) }
  end
end
