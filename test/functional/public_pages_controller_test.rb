require 'test_helper'

class PublicPagesControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers
  
  setup do
    @org = Org.first
    scaffold_plan
    
    @plan.visibility = :publicly_visible
    @plan.save
    
    @non_public_plans = []
    [:privately_visible, :organisationally_visible, :is_test].each do |vis|
      @non_public_plans << Plan.create(template: @template, title: "#{vis} Plan", visibility: vis,
                                       roles: [Role.new(user: User.last, creator: true)])
    end

    @inst_tmplt = Template.create!(title: 'Inst template', org: Org.institution.first, archived: false, published: true)
    @dflt_tmplt = Template.create!(title: 'Dflt template', org: Org.managing_orgs.first, archived: false, published: true)
    @fndr_tmplt = Template.create!(title: 'Fndr template', org: Org.funder.first, archived: false, published: true)

    [@inst_tmplt, @dflt_tmplt, @fndr_tmplt].each do |t|
      t.published = true
      t.is_default = true if t == @dflt_tmplt
      t.visibility = t.title != 'Inst template' ? Template.visibilities[:publicly_visible] : Template.visibilities[:organisationally_visible]
      t.save!
    end

    @user = User.first
  end

  # GET /public_plans (public_plans_path)
  # ----------------------------------------------------------
  test 'load the list of public plans page' do
    # Verify that public plans are visible when not logged in and that non-public plans are NOT in the list
    get public_plans_path
    assert_response :success
    assert assigns(:plans)
    assert @response.body.include?(plan_export_path(@plan)), "expected to see the plan download link when NOT logged in"
    @non_public_plans.each do |plan|
      assert_not @response.body.include?(plan_export_path(plan)), "expected to NOT see the on-public plan download link when NOT logged in"
    end
    
    # Verify the same results are received when the user is logged in
    sign_in @user
    get public_plans_path
    assert_response :success
    assert assigns(:plans)
    assert @response.body.include?(plan_export_path(@plan)), "expected to see the plan download link when NOT logged in"
    @non_public_plans.each do |plan|
      assert_not @response.body.include?(plan_export_path(plan)), "expected to NOT see the on-public plan download link when NOT logged in"
    end
  end
  
# TODO: Need to install the wkhtmltopdf library on Travis for this to work!
  # GET /plan_export/:id (plan_export_path)
  # ----------------------------------------------------------
  test 'export a public plan' do
#    get plan_export_path(@plan, format: :pdf)
#    assert_response :success

#    @non_public_plans.each do |p|
#      get plan_export_path(p, format: :pdf)
#      assert_response :redirect
#      assert_equal "You need to sign in or sign up before continuing.", flash[:alert]
#      assert_redirected_to root_path
#    end
  end
  
  # GET /public_templates (public_templates_path)
  # ----------------------------------------------------------
  test 'load the list of public templates page' do
    # Verify that public templates are visible when not logged in and that non-funder and non-default 
    # templates are NOT in the list
    get public_templates_path
    assert_response :success
    assert assigns(:templates)
    assert @response.body.include?(template_export_path(@fndr_tmplt.family_id)), "expected to see the funder template download link when NOT logged in"
    assert @response.body.include?(template_export_path(@dflt_tmplt.family_id)), "expected to see the default template download link when NOT logged in"
    assert_not @response.body.include?(template_export_path(@inst_tmplt.family_id)), "expected to NOT see the institution template download link when NOT logged in"

    # Verify the same results are received when the user is logged in
    sign_in @user
    get public_templates_path
    assert_response :success
    assert assigns(:templates)
    assert @response.body.include?(template_export_path(@fndr_tmplt.family_id)), "expected to see the funder template download link when NOT logged in"
    assert @response.body.include?(template_export_path(@dflt_tmplt.family_id)), "expected to see the default template download link when NOT logged in"
    assert_not @response.body.include?(template_export_path(@inst_tmplt.family_id)), "expected to NOT see the institution template download link when NOT logged in"
  end
  
# TODO: Need to install the wkhtmltopdf library on Travis for this to work!
  # GET /template_export/:family_id (template_export_path)
  # ----------------------------------------------------------
  test 'export a public template' do
#    get template_export_path(@fndr_tmplt.family_id, format: :pdf)
#    assert_response :success

#    get template_export_path(@dflt_tmplt.family_id, format: :pdf)
#    assert_response :success

#    get template_export_path(@inst_tmplt.family_id, format: :pdf)
#    assert_response :redirect
#    assert_equal "You need to sign in or sign up before continuing.", flash[:alert]
#    assert_redirected_to root_path
  end
end