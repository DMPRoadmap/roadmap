require 'test_helper'

class TemplatesControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  setup do
    @funder = init_funder
    @institution = init_institution
    @organisation = init_organisation
    
    @researcher = init_researcher(@institution)
    @org_admin = init_org_admin(@institution)
    @super_admin = init_super_admin(@organisation)
    
    @funder_template = init_template(@funder, {
      title: 'Test Funder Template', 
      published: true, 
      visibility: Template.visibilities[:publicly_visible]
    })
    @org_template = init_template(@institution, {
      title: 'Test Org Template', 
      published: true
    })
  end

  test "unauthorized user cannot access the templates#index page" do
    get org_admin_templates_path
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    get org_admin_templates_path
    assert_authorized_redirect_to_plans_page
    sign_in @org_admin
    get org_admin_templates_path
    assert_authorized_redirect_to_plans_page
  end

  test "authorized user can access the templates#index page" do
    sign_in @super_admin
    get org_admin_templates_path
    assert_response :success
  end

  test "unauthorized user cannot access the templates#organisational page" do
    get organisational_org_admin_templates_path
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    get organisational_org_admin_templates_path
    assert_authorized_redirect_to_plans_page
  end

  test "authorized user can access the templates#organisational page" do
    sign_in @org_admin
    get organisational_org_admin_templates_path
    assert_response :success
  end
  
  test "unauthorized user cannot access the templates#customisable page" do
    get customisable_org_admin_templates_path
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    get customisable_org_admin_templates_path
    assert_authorized_redirect_to_plans_page
  end
  
  test "authorized user can access the templates#customisable page" do
    sign_in @org_admin
    get customisable_org_admin_templates_path
    assert_response :success
  end
  
  test "unauthorized user cannot access the template#edit page" do
    get edit_org_admin_template_path(@org_template)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    get edit_org_admin_template_path(@org_template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "authorized user can access the template#edit page" do
    sign_in @org_admin
    get edit_org_admin_template_path(@org_template)
    assert_response :success
  end

  test "admin cannot access another org's template#edit page" do
    sign_in @org_admin
    get edit_org_admin_template_path(@funder_template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "super admin can access any org's template#edit page" do
    sign_in @super_admin
    [@org_template, @funder_template].each do |template|
      get edit_org_admin_template_path(template)
      assert_response :success
    end
  end

  test 'get templates#edit returns ok when template is latest' do
    sign_in @org_admin
    get(edit_org_admin_template_path(@org_template))
    assert_response :success
    assert_nil flash[:notice], 'expected no warning messages'
  end

  test 'get templates#edit returns ok with flash notice when template is not latest' do
    new_version = @org_template.generate_version!
    sign_in @org_admin
    get(edit_org_admin_template_path(@org_template.id))
    assert_response :success
    assert_not_nil flash[:notice], 'expected a warning message'
  end

  test "unauthorized user cannot access the template#new page" do
    get new_org_admin_template_path
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    get new_org_admin_template_path
    assert_authorized_redirect_to_plans_page
  end
  
  test "authorized user can access the template#new page" do
    sign_in @org_admin
    get new_org_admin_template_path
    assert_response :success
  end
  
  test "unauthorized user cannot access the template#history page" do
    get history_org_admin_template_path(@org_template)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    get history_org_admin_template_path(@org_template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "authorized user can access the template#history page" do
    sign_in @org_admin
    get history_org_admin_template_path(@org_template)
    assert_response :success
  end

  test "unauthorized user cannot access template#delete" do
    delete org_admin_template_path(@org_template)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    delete org_admin_template_path(@org_template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "authorized user can access template#delete" do
    sign_in @org_admin
    delete org_admin_template_path(@org_template)
    assert_response :redirect
    assert_redirected_to org_admin_templates_path
    assert_nil flash[:alert]
  end

  test "unauthorized user cannot create a template#create" do
    post org_admin_templates_path(@institution), {template: {title: ''}}
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    post org_admin_templates_path(@institution), {template: {title: ''}}
    assert_authorized_redirect_to_plans_page
  end
  
  test "authorized user can create a template#create" do
    params = {title: 'Testing create route'}
    sign_in @org_admin

    post org_admin_templates_path(@institution), {template: params}
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('created')
    assert_response :redirect
    assert_redirected_to edit_org_admin_template_url(Template.last.id)
  end
  
  test "unauthorized user cannot update a template#update" do
    put org_admin_template_path(@org_template), {template: {title: ''}}
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    put org_admin_template_path(@org_template), {template: {title: ''}}
    assert_authorized_redirect_to_plans_page
  end

  test "authorized user can update the template#update" do
    params = {title: 'ABCD'}
    sign_in @org_admin
    put org_admin_template_path(@org_template), {template: params}
    assert_response :ok
    json_body = ActiveSupport::JSON.decode(response.body)
    assert json_body["msg"].start_with?('Successfully') && json_body["msg"].include?('saved')
  end

  test "unauthorized user cannot customize a template#customize" do
    post customize_org_admin_template_path(@org_template)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    post customize_org_admin_template_path(@org_template)
    assert_authorized_redirect_to_plans_page
  end

  test "authorized user can customize a funder template#customize" do
    @funder_template.update!({ published: true })
    sign_in @org_admin
    post customize_org_admin_template_path(@funder_template)
    assert_response :redirect
    assert_redirected_to org_admin_template_url(Template.latest_customized_version(@funder_template.family_id, @institution.id).first)
  end

  test "unauthorized user cannot publish a template#publish" do
    patch publish_org_admin_template_path(@org_template)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    patch publish_org_admin_template_path(@org_template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "authorized user cannot publish another org's template#publish" do
    sign_in @org_admin
    patch publish_org_admin_template_path(@funder_template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "authorized user can publish a template#publish" do
    sign_in @org_admin
    patch publish_org_admin_template_path(@org_template)
    assert_equal _('Your template has been published and is now available to users.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to org_admin_templates_path
  end

  test "unauthorized user cannot unpublish a template#unpublish" do
    patch unpublish_org_admin_template_path(@org_template)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    patch unpublish_org_admin_template_path(@org_template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "authorized user can unpublish a template#unpublish" do
    sign_in @org_admin
    patch unpublish_org_admin_template_path(@org_template)
    assert_response :redirect
    assert_redirected_to org_admin_templates_path
  end
  
  test "unauthorized user cannot copy a template#copy" do
    post copy_org_admin_template_path(@org_template)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    post copy_org_admin_template_path(@org_template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "unauthorized user cannot copy another org's template template#copy" do
    sign_in @researcher
    post copy_org_admin_template_path(@funder_template)
    assert_response :redirect
    assert_authorized_redirect_to_plans_page
  end
  
  test "authorized super admin can copy another org's template template#copy" do
    sign_in @super_admin
    post copy_org_admin_template_path(@funder_template)
    assert_response :redirect
    assert_redirected_to edit_org_admin_template_url(Template.where(org_id: @organisation.id).order(id: :desc).last)
  end
  
  test "authorized user can copy a template#copy" do
    sign_in @org_admin
    post copy_org_admin_template_path(@org_template)
    assert_response :redirect
    assert_redirected_to edit_org_admin_template_url(Template.where(org_id: @institution.id).last)
  end

  test "unauthorized user cannot transfer a template customization template#transfer_customization" do
    post transfer_customization_org_admin_template_path(@org_template)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    post transfer_customization_org_admin_template_path(@org_template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "authorized user can transfer a template customization template#transfer_customization" do
# TODO: This will not work because Rails is persisting these transactions to the DB at the same time, so their created_at 
#       timestamps match even if we add a 'sleep' statement. The template.upgrade_customization? will fail because of this.
#    sign_in @org_admin
#    original = @funder_template.customize!(@organisation)
#    # Add a phase to the funder template and republish it
#    phase = init_phase(@funder_template, { title: 'testing transfer of customizations' })
#    phase.template.update!({ published: true, title: 'upgraded funder template' })
#    post transfer_customization_org_admin_template_path(original)
#    assert_response :redirect
#    assert_redirected_to edit_org_admin_template_url(Template.latest_customized_version(@funder_template.family_id, @organisation.id).first)
  end
  
  test "unauthorized user cannot get template#template_options" do
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]=#{@funder.id}"
    assert_unauthorized_redirect_to_root_path
  end
  
  test "authorized user can get template#template_options" do
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]=#{@funder.id}"
    assert_response :success
    json_body = JSON.parse(@response.body)
    assert json_body["templates"].length > 0
  end
end
