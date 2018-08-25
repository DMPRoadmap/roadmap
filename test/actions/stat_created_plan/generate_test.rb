require 'minitest/mock'
require_relative '../../../app/actions/stat_created_plan/generate'

class Actions::StatCreatedPlan::GenerateTest < ActiveSupport::TestCase
  test "full returns monthly aggregates since org's creation" do
    org = create_org(created_at: DateTime.new(2018,04,01))
    template = create_template(org)
    user1 = create_user(org: org)
    user2 = create_user(org: org)
    plan = create_plan(template: template, created_at: DateTime.new(2018, 04, 01))
    plan2 = create_plan(template: template, created_at: DateTime.new(2018, 04, 03))
    plan3 = create_plan(template: template, created_at: DateTime.new(2018, 05, 02))
    plan4 = create_plan(template: template, created_at: DateTime.new(2018, 06, 02))
    plan5 = create_plan(template: template, created_at: DateTime.new(2018, 06, 03))
    assign_owner(plan: plan, user: user1)
    assign_coowner(plan: plan, user: user2)
    assign_owner(plan: plan2, user: user1)
    assign_owner(plan: plan3, user: user1)
    assign_coowner(plan: plan4, user: user2)
    assign_coowner(plan: plan5, user: user2)

    Actions::StatCreatedPlan::Generate.full(org)

    april_count = StatCreatedPlan.find_by(date: '2018-04-30', org_id: org.id).count
    may_count = StatCreatedPlan.find_by(date: '2018-05-31', org_id: org.id).count
    june_count = StatCreatedPlan.find_by(date: '2018-06-30', org_id: org.id).count
    july_count = StatCreatedPlan.find_by(date: '2018-07-31', org_id: org.id).count

    assert_equal(2, april_count)
    assert_equal(1, may_count)
    assert_equal(2, june_count)
    assert_equal(0, july_count)
  end

  test "last_month returns aggregates from today's last month" do
    org = create_org(created_at: DateTime.new(2018,04,01))
    template = create_template(org)
    user1 = create_user(org: org)
    user2 = create_user(org: org)
    plan = create_plan(template: template, created_at: Date.today.last_month.end_of_month)
    plan2 = create_plan(template: template, created_at: Date.today.last_month.end_of_month)
    plan3 = create_plan(template: template, created_at: Date.today.last_month.end_of_month)
    assign_owner(plan: plan, user: user1)
    assign_coowner(plan: plan, user: user2)
    assign_owner(plan: plan2, user: user1)
    assign_owner(plan: plan3, user: user2)

    Actions::StatCreatedPlan::Generate.last_month(org)

    last_month_count = StatCreatedPlan.find_by(date: Date.today.last_month.end_of_month, org_id: org.id).count
    assert_equal(3, last_month_count)
  end

  test "full_all_orgs returns monthly aggregates for each org since their creation" do
    org = create_org(created_at: DateTime.new(2018,04,01))
    template = create_template(org)
    user1 = create_user(org: org)
    user2 = create_user(org: org)
    plan = create_plan(template: template, created_at: DateTime.new(2018, 04, 01))
    plan2 = create_plan(template: template, created_at: DateTime.new(2018, 04, 03))
    plan3 = create_plan(template: template, created_at: DateTime.new(2018, 05, 02))
    plan4 = create_plan(template: template, created_at: DateTime.new(2018, 06, 02))
    plan5 = create_plan(template: template, created_at: DateTime.new(2018, 06, 03))
    assign_owner(plan: plan, user: user1)
    assign_coowner(plan: plan, user: user2)
    assign_owner(plan: plan2, user: user1)
    assign_owner(plan: plan3, user: user1)
    assign_coowner(plan: plan4, user: user2)
    assign_coowner(plan: plan5, user: user2)

    Org.stub :all, [org] do
      Actions::StatCreatedPlan::Generate.full_all_orgs

      april_count = StatCreatedPlan.find_by(date: '2018-04-30', org_id: org.id).count
      may_count = StatCreatedPlan.find_by(date: '2018-05-31', org_id: org.id).count
      june_count = StatCreatedPlan.find_by(date: '2018-06-30', org_id: org.id).count
      july_count = StatCreatedPlan.find_by(date: '2018-07-31', org_id: org.id).count

      assert_equal(2, april_count)
      assert_equal(1, may_count)
      assert_equal(2, june_count)
      assert_equal(0, july_count)
    end
  end

  test "last_month_all_orgs returns aggregates from today's last month" do
    org = create_org(created_at: DateTime.new(2018,04,01))
    template = create_template(org)
    user1 = create_user(org: org)
    user2 = create_user(org: org)
    plan = create_plan(template: template, created_at: Date.today.last_month.end_of_month)
    plan2 = create_plan(template: template, created_at: Date.today.last_month.end_of_month)
    plan3 = create_plan(template: template, created_at: Date.today.last_month.end_of_month)
    assign_owner(plan: plan, user: user1)
    assign_coowner(plan: plan, user: user2)
    assign_owner(plan: plan2, user: user1)
    assign_owner(plan: plan3, user: user2)

    Org.stub :all, [org] do
      Actions::StatCreatedPlan::Generate.last_month_all_orgs

      last_month_count = StatCreatedPlan.find_by(date: Date.today.last_month.end_of_month, org_id: org.id).count
      assert_equal(3, last_month_count)
    end
  end

  def create_user(org: , created_at: DateTime.current)
    user = User.new(user_seed.merge({ org: org, email: "user#{Random.new.rand(100000)}@example.com" }))
    user.save!
    user.created_at = created_at
    user.save!
    user
  end

  def create_org(created_at: DateTime.current)
    org = Org.create!(org_seed.merge({ name: "org#{Random.new.rand(100000)}" }))
    org.created_at = created_at
    org.save!
    org
  end

  def create_template(org)
    template = Template.create!(template_seed.merge({ org: org }))
  end

  def create_plan(template:, created_at: DateTime.current)
    plan = Plan.create!(plan_seed.merge({ template: template }))
    plan.created_at = created_at
    plan.save!
    plan
  end

  def assign_owner(plan:, user: )
    creator = Role.access_values_for(:creator)
    role = Role.create!(plan: plan, user: user, access: creator.first) 
    role
  end

  def assign_coowner(plan:, user: )
    administrator = Role.access_values_for(:administrator)
    role = Role.create!(plan: plan, user: user, access: administrator.first)
    role
  end
end
