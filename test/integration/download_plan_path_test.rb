require 'test_helper'

class DownloadPlanPathTest < ActionDispatch::IntegrationTest
	include Devise::Test::IntegrationHelpers

  setup do
  	@org = init_organisation
    template = init_template(@org)
    phase = init_phase(template)
    section = init_section(phase)
    init_question(section)
    @plan = init_plan(template)
    @user = User.create(user_seed.merge({ org: @org }))
  end

  def assert_download_link_present(plan, user)
  	sign_in user
  	get(download_plan_path(plan))
  	links = css_select("a[href=\"#{download_plan_path(plan)}\"]")
  	refute_empty(links)
  	assert_equal(links[0].text, _('Download'))
  end

  def refute_download_link_present(plan, user)
  	sign_in user
  	get(download_plan_path(plan))
  	links = css_select("a[href=\"#{download_plan_path(plan)}\"]")
  	assert_empty(links)
  end

  test 'download tab is visible when user has role creator, administrator, commenter, editor on the plan' do
  	assign_roles = [
  		lambda{ |plan, user| plan.assign_creator(user.id) },
  		lambda{ |plan, user| plan.assign_administrator(user.id) },
  		lambda{ |plan, user| plan.assign_editor(user.id) },
  		lambda{ |plan, user| plan.assign_reader(user.id) }
  	]
  	assign_roles.each do |assign_role|
  		assign_role.call(@plan, @user)
  		assert_download_link_present(@plan, @user)
  	end
  end

  test 'download tab is visible when user is super_admin' do
  	@user.perms = Perm.all
  	assert_download_link_present(@plan, @user)
  end

  test 'download tab is visible when user is an org_admin from the same org that any owner\'s org' do
  	@plan.assign_creator(@user.id)
  	user2 = User.create(user_seed.merge({ org: @org, email: 'foo@bar.com' }))
  	user2.perms << Perm.grant_permissions
  	assert_download_link_present(@plan, user2)
  end

  test 'download tab is NOT visible when user is an org_admin from an org different from every owner\'s org' do
  	@plan.assign_creator(@user.id)
  	user2 = User.create(user_seed.merge({ org: init_funder_organisation, email: 'foo@bar.com' }))
  	user2.perms << Perm.grant_permissions
  	refute_download_link_present(@plan, user2)
  end

  test 'download tab is NOT visible when user is not super_admin nor org_admin nor has commenter role' do
  	@plan.roles << Role.new(user_id: @user.id, reviewer: true)
  	refute_download_link_present(@plan, @user)
  end 
end