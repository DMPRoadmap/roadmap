require 'test_helper'

class TemplatesControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  setup do
    scaffold_template

    # Get the first Org Admin
    scaffold_org_admin(@template.org)
    
    @regular_user = User.find_by(email: 'org_user@example.com') 
  end

  test "unauthorized user cannot access the templates page" do
    # Should redirect user to the root path if they are not logged in!
    get org_admin_templates_path
    assert_unauthorized_redirect_to_root_path
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    get org_admin_templates_path
    assert_authorized_redirect_to_plans_page
  end
  
  test "Org Admin should see the list of their templates and customizable funder templates" do
    sign_in @user
    get org_admin_templates_path
    assert_response :success
    assert_select "#organisation-templates table tbody tr", @user.org.templates.length, "expected the Org Admin to only see their own templates"
  end
  
  test "Super Admin should see the list of all templates" do
    user = User.find_by(email: 'super_admin@example.com')
    sign_in user
    get org_admin_templates_path
    assert_response :success
    assert_select "#organisation-templates table tbody tr", Template.where(org: Org.not_funder).pluck(:dmptemplate_id).uniq.length, "expected the Super Admin to see all of the templates"
  end

  test "unauthorized user cannot access the template edit page" do
    # Should redirect user to the root path if they are not logged in!
    get edit_org_admin_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    get edit_org_admin_template_path(@template)
    assert_authorized_redirect_to_plans_page
  end

  test "get the template edit page" do
    sign_in @user

    get edit_org_admin_template_path(@template)
    assert_response :success

    assert assigns(:template)
    assert assigns(:template_hash)
    assert assigns(:current)
  end

  test "unauthorized user cannot access the new template page" do
    # Should redirect user to the root path if they are not logged in!
    get new_org_admin_template_path(Template.last.id)
    assert_unauthorized_redirect_to_root_path
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    get new_org_admin_template_path(Template.last.id)
    assert_authorized_redirect_to_plans_page
  end
  
  test "get the new template page" do
    sign_in @user

    get new_org_admin_template_path(Template.last.id)
    assert_response :success
  end

  test "unauthorized user cannot access the template history page" do
    # Should redirect user to the root path if they are not logged in!
    get history_org_admin_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    get history_org_admin_template_path(@template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "get the template history page" do
    sign_in @user

    get history_org_admin_template_path(@template)
    assert_response :success

    assert assigns(:template)
    assert assigns(:templates)
    assert assigns(:current)
  end

  test "unauthorized user cannot delete a template" do
    # Should redirect user to the root path if they are not logged in!
    delete org_admin_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    delete org_admin_template_path(@template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "delete the admin template" do
    id = @template.id
    sign_in @user

    family = @template.dmptemplate_id
    prior = Template.current(family)

    version_the_template

    current = Template.current(family)

    # Try to delete a historical version should fail
    delete org_admin_template_path(prior)
    assert_equal _('You cannot delete historical versions of this template.'), flash[:alert]
    assert_response :redirect
    assert_redirected_to org_admin_templates_path
    assert_not Template.find(prior.id).nil?

    # Try to delete the current version should work
    delete org_admin_template_path(current)
    assert_response :redirect
    assert_redirected_to org_admin_templates_path
    assert_raise ActiveRecord::RecordNotFound do
      Template.find(current.id).nil?
    end
    assert_equal prior, Template.current(family), "expected the old version to now be the current version"
    
    # Should not be able to delete a template that has plans!
  end

  test "unauthorized user cannot create a template" do
    # Should redirect user to the root path if they are not logged in!
    post org_admin_templates_path(@user.org), {template: {title: ''}}
    assert_unauthorized_redirect_to_root_path
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    post org_admin_templates_path(@user.org), {template: {title: ''}}
    assert_authorized_redirect_to_plans_page
  end
  
  test "create a template" do
    params = {title: 'Testing create route'}
    sign_in @user

    post org_admin_templates_path(@user.org), {template: params}
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('created')
    assert_response :redirect
    assert_redirected_to edit_org_admin_template_url(Template.last.id)
    assert assigns(:template)
    assert_equal 'Testing create route', Template.last.title, "expected the record to have been created!"

    # Invalid object
    post org_admin_templates_path(@user.org), {template: {title: nil, org_id: @user.org.id}}
    assert flash[:alert].starts_with?(_('Could not create your'))
    assert_response :success
    assert assigns(:template)
    assert assigns(:hash)
  end
  
  test "unauthorized user cannot update a template" do
    # Should redirect user to the root path if they are not logged in!
    put org_admin_template_path(@template), {template: {title: ''}}
    assert_unauthorized_redirect_to_root_path
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    put org_admin_template_path(@template), {template: {title: ''}}
    assert_authorized_redirect_to_plans_page
  end

  test "update the template" do
    params = {title: 'ABCD'}
    sign_in @user

    family = @template.dmptemplate_id
    prior = Template.current(family)

    version_the_template

    current = Template.current(family)

    # We shouldn't be able to edit a historical version
    put org_admin_template_path(prior), {template: params}
    assert_response :forbidden
    json_body = ActiveSupport::JSON.decode(response.body)
    assert_equal(_('You can not edit a historical version of this template.'), json_body["msg"])

    # Make sure we get the right response when editing an unpublished template
    put org_admin_template_path(current), {template: params}
    assert_response :ok
    json_body = ActiveSupport::JSON.decode(response.body)
    assert json_body["msg"].start_with?('Successfully') && json_body["msg"].include?('saved')
    assert_equal('ABCD', current.reload.title, "expected the record to have been updated")
    assert current.reload.dirty?

    # Make sure we get the right response when providing an invalid template
    put org_admin_template_path(current), {template: {title: nil}}
    assert_response :bad_request
    json_body = ActiveSupport::JSON.decode(response.body)
    assert json_body["msg"].starts_with?(_('Could not update your'))
  end

  test "unauthorized user cannot customize a template" do
    # Make sure we are redirected if we're not logged in
    get customize_org_admin_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    get customize_org_admin_template_path(@template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "customize a funder template" do
    funder_template = Template.create(org: Org.funder.first, title: 'Testing integration')

    # Sign in as the funder so that we cna publish the template
    sign_in User.find_by(org: funder_template.org)

    get publish_org_admin_template_path(funder_template)
    assert_response :redirect
    assert_redirected_to org_admin_templates_path

    # Sign in as the regular user so we can customize the funder template
    sign_in @user

    template = Template.live(funder_template.dmptemplate_id)

    get customize_org_admin_template_path(template)

    customization = Template.where(customization_of: template.dmptemplate_id).last

    assert_response :redirect
    assert_redirected_to edit_org_admin_template_url(Template.last)
    assert assigns(:template)

    assert_equal 0, customization.version
    assert_not customization.published?
    assert customization.dirty?

    # Make sure the funder templates data is not modifiable!
    customization.phases.each do |p|
      assert_not p.modifiable
      p.sections.each do |s|
        assert_not s.modifiable
        s.questions.each do |q|
          assert_not q.modifiable
        end
      end
    end
  end

  test "unauthorized user cannot publish a template" do
    # Should redirect user to the root path if they are not logged in!
    get publish_org_admin_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    get publish_org_admin_template_path(@template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "publish a template" do
    sign_in @user

    family = @template.dmptemplate_id
    prior = Template.current(family)

    version_the_template

    current = Template.current(family)

    # We shouldn't be able to edit a historical version
    get publish_org_admin_template_path(prior)
    assert_equal _('You can not publish a historical version of this template.'), flash[:alert]
    assert_response :redirect
    assert_redirected_to org_admin_templates_path
    assert assigns(:template)

    # Publish the current template
    get publish_org_admin_template_path(current)
    assert_equal _('Your template has been published and is now available to users.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to org_admin_templates_path
    current = Template.current(family)

    # Update the description so that the template gets versioned
    get edit_org_admin_template_path(current) # Click on 'edit'
    new_version = Template.current(family)    # Edit working copy
    put org_admin_template_path(new_version), {template: {description: "this is an update"}}

    # Make sure it versioned properly
    new_version = Template.current(family)
    assert_not_equal current.id = new_version.id, "expected it to create a new version"
    assert_equal (current.version + 1), new_version.version, "expected the version to have incremented"
    assert current.published?, "expected the old version to be published"
    assert_not new_version.published?, "expected the new version to NOT be published"
    assert_not current.dirty?, "expected the old dirty flag to be false"
    assert new_version.dirty?, "expected the new dirty flag to be true"
    assert_equal current.dmptemplate_id, new_version.dmptemplate_id, "expected the old and new versions to share the same dmptemplate_id"
  end

  test "unauthorized user cannot unpublish a template" do
    # Should redirect user to the root path if they are not logged in!
    get unpublish_org_admin_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    get unpublish_org_admin_template_path(@template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "unpublish a template" do
    sign_in @user

    family = @template.dmptemplate_id
    prior = Template.current(family)

    version_the_template

    current = Template.current(family)

    # Publish it so we can unpublish
    get publish_org_admin_template_path(current)
    assert_not Template.live(family).nil?

    get unpublish_org_admin_template_path(current)
    assert_equal _('Your template is no longer published. Users will not be able to create new DMPs for this template until you re-publish it'), flash[:notice]
    assert_response :redirect
    assert_redirected_to org_admin_templates_path

    # Make sure there are no published versions
    assert Template.live(family).nil?
  end
  
  test "unauthorized user cannot copy a template" do
    # Should redirect user to the root path if they are not logged in!
    get copy_org_admin_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    get copy_org_admin_template_path(@template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "copy a template" do
    sign_in @user
    get copy_org_admin_template_path(@template)
    assert_response :redirect
    assert_redirected_to "#{edit_org_admin_template_url(Template.last)}?edit=true"
  end
  
  test "unauthorized user cannot transfer a template customization" do
    # Should redirect user to the root path if they are not logged in!
    get transfer_customization_org_admin_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    get transfer_customization_org_admin_template_path(@template)
    assert_authorized_redirect_to_plans_page
  end
  
  test "transfer a template customization" do
    # TODO add test for this. Could not get working, getting a nil for max_version within the method (NOT SURE IF THIS IS STILL IN USE!)
  end
end
