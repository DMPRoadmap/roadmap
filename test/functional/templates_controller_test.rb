require 'test_helper'

class TemplatesControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    scaffold_template
    
    # Get the first Org Admin
    scaffold_org_admin(@template.org)
  end

# TODO: The following methods SHOULD replace the old 'admin_' prefixed methods. The routes file already has
#       these defined. We should remove the old routes to the 'admin_' prefixed methods as well. We should just
#       have:
#
# SHOULD BE:
# --------------------------------------------------
#   templates               GET    /templates           templates#index
#                           POST   /templates           templates#create
#   template                GET    /template/[:id]      templates#show
#                           PATCH  /template/[:id]      templates#update
#                           PUT    /template/[:id]      templates#update
#                           DELETE /template/[:id]      templates#destroy
#   edit_template           GET    /template/[:id]/edit templates#edit
#   new_template            GET    /templates/new       templates#new
#
#
# CURRENT RESULTS OF `rake routes`
# --------------------------------------------------
#   admin_index_template    GET    /org/admin/templates/:id/admin_index(.:format)          templates#admin_index
#   admin_template_template GET    /org/admin/templates/:id/admin_template(.:format)       templates#admin_template
#   admin_new_template      GET    /org/admin/templates/:id/admin_new(.:format)            templates#admin_new
#   admin_template_history_template GET /org/admin/templates/:id/admin_template_history(.:format) templates#admin_template_history
#   admin_destroy_template  DELETE /org/admin/templates/:id/admin_destroy(.:format)        templates#admin_destroy
#   admin_create_template   POST   /org/admin/templates/:id/admin_create(.:format)         templates#admin_create
#   admin_update_template   PUT    /org/admin/templates/:id/admin_update(.:format)         templates#admin_update
  
  
  # GET /org/admin/templates/:id/admin_index (admin_index_template_path) the :id here makes no sense!
  # ----------------------------------------------------------
  test "get the list of admin templates" do
    # Should redirect user to the root path if they are not logged in!
    get admin_index_template_path(@user.org)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_index_template_path(@user.org)
    assert_response :success
    
    assert assigns(:funder_templates)
    assert assigns(:org_templates)
  end 
  
  # GET /org/admin/templates/:id/admin_template (admin_template_template_path)
  # ----------------------------------------------------------
  test "get the admin template" do
    # Should redirect user to the root path if they are not logged in!
    get admin_template_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_template_template_path(@template)
    assert_response :success
    
    assert assigns(:template)
    assert assigns(:hash)
    assert assigns(:current)
  end
  
#  TODO: Why are we passing an :id here!? Its a new record but we seem to need the last template's id
  # GET /org/admin/templates/:id/admin_new (admin_new_template_path)
  # ----------------------------------------------------------
  test "get the new admin template page" do
    # Should redirect user to the root path if they are not logged in!
    get admin_new_template_path(Template.last.id)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_new_template_path(Template.last.id)
    assert_response :success
  end
  
  # GET /org/admin/templates/:id/admin_template_history (admin_template_history_template_path)
  # ----------------------------------------------------------
  test "get the admin template history page" do
    # Should redirect user to the root path if they are not logged in!
    get admin_template_history_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_template_history_template_path(@template)
    assert_response :success
    
    assert assigns(:template)
    assert assigns(:templates)
    assert assigns(:current)
  end
  
  # DELETE /org/admin/templates/:id/admin_destroy (admin_destroy_template_path)
  # ----------------------------------------------------------
  test "delete the admin template" do
    id = @template.id
    # Should redirect user to the root path if they are not logged in!
    delete admin_destroy_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    family = @template.dmptemplate_id
    prior = Template.current(@template.org, family)
    
    version_the_template
    
    current = Template.current(@template.org, family)
    
    # Try to delete a historical version should fail
    delete admin_destroy_template_path(prior)
    assert_equal _('You cannot delete historical versions of this template.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to admin_index_template_path
    assert_not Template.find(prior.id).nil?

    # Try to delete the current version should work
    delete admin_destroy_template_path(current)
    assert_response :redirect
    assert_redirected_to admin_index_template_path
    assert_raise ActiveRecord::RecordNotFound do 
      Template.find(current.id).nil?
    end
    assert_equal prior, Template.current(@template.org, family), "expected the old version to now be the current version"
  end
  
#  TODO: Why are we passing an :id here!? Its a new record but we seem to need the last template's id
  # POST /org/admin/templates/:id/admin_create (admin_create_template_path)
  # ----------------------------------------------------------
  test "create a template" do
    params = {title: 'Testing create route'}
    
    # Should redirect user to the root path if they are not logged in!
    post admin_create_template_path(Template.last.id), {template: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    post admin_create_template_path(Template.last.id), {template: params}
    assert_equal _('Information was successfully created.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to admin_template_template_url(Template.last.id)
    assert assigns(:template)
    assert_equal 'Testing create route', Template.last.title, "expected the record to have been created!"
    
    # Invalid object
    post admin_create_template_path(Template.last.id), {template: {title: nil, org_id: @user.org.id}}
    assert flash[:notice].starts_with?(_('Could not create your'))
    assert_response :success
    assert assigns(:template)
    assert assigns(:hash)
  end
  
  # GET /org/admin/templates/:id/admin_update (admin_update_template_path)
  # ----------------------------------------------------------
  test "update the admin template" do
    params = {title: 'ABCD'}
    
    # Should redirect user to the root path if they are not logged in!
    put admin_update_template_path(@template), {template: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user

    family = @template.dmptemplate_id
    prior = Template.current(@template.org, family)
    
    version_the_template
    
    current = Template.current(@template.org, family)

    # We shouldn't be able to edit a historical version
    put admin_update_template_path(prior), {template: params}
    assert_equal _('You can not edit a historical version of this template.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to admin_template_template_url(prior)
    assert assigns(:template)
    
    # Make sure we get the right response when editing an unpublished template
    put admin_update_template_path(current), {template: params}
    assert_equal _('Information was successfully updated.'), flash[:notice]
    assert_response :success
    assert assigns(:template)
    assert assigns(:hash)
    assert_equal 'ABCD', current.reload.title, "expected the record to have been updated"
    assert current.reload.dirty? 
    
    # Make sure we get the right response when providing an invalid template
    put admin_update_template_path(current), {template: {title: nil}}
    assert flash[:notice].starts_with?(_('Could not update your'))
    assert_response :success
    assert assigns(:template)
    assert assigns(:hash)
  end

  # GET /org/admin/templates/:id/admin_customize (admin_customize_template_path)
  # ----------------------------------------------------------
  test "customize a funder template" do
    funder = Org.funders.first
    ids = Template.dmptemplate_ids(funder)
    
    template = Template.live(funder, ids.last)
    
    # Make sure we are redirected if we're not logged in
    put admin_customize_template_path(template)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    put admin_customize_template_path(template)
    
    customization = Template.where(org: @user.org, customization_of: template.dmptemplate_id).last

    assert_response :redirect
    assert_redirected_to admin_template_template_url(Template.last)
    assert assigns(:template)
    
    assert_equal 0, customization.version
    assert_not customization.published?
    assert_not customization.dirty?
    
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
  
  # GET /org/admin/templates/:id/admin_publish (admin_publish_template_path)
  # ----------------------------------------------------------
  test "publish a template" do
    # Should redirect user to the root path if they are not logged in!
    put admin_publish_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user

    family = @template.dmptemplate_id
    prior = Template.current(@user.org, family)
    
    version_the_template
    
    current = Template.current(@user.org, family)

    # We shouldn't be able to edit a historical version
    put admin_publish_template_path(prior)
    assert_equal _('You can not publish a historical version of this template.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to admin_template_template_url(prior)
    assert assigns(:template)
    
    # Publish the current template
    put admin_publish_template_path(current)
    assert_response :redirect
    assert_redirected_to admin_index_template_path(@user.org)
    
    # Make sure it versioned properly
    current = Template.includes(:phases, :sections, :questions).find(current.id)
    new_version = Template.current(@user.org, family)
    assert_not_equal current.id = new_version.id, "expected it to create a new version"
    assert_equal (current.version + 1), new_version.version, "expected the version to have incremented"
    assert current.published?, "expected the old version to be published"
    assert_not new_version.published?, "expected the new version to NOT be published"
    assert_not current.dirty?, "expected the old dirty flag to be false"
    assert_not new_version.dirty?, "expected the new dirty flag to be false"
    assert_equal current.dmptemplate_id, new_version.dmptemplate_id, "expected the old and new versions to share the same dmptemplate_id"
    
    # The old version's phases/sections/questions should NOT be modifiable
    current.phases.each do |p|
      assert_not p.modifiable?
      p.sections.each do |s|
        assert_not s.modifiable?
        s.questions.each do |q|
          assert_not q.modifiable?
        end
      end
    end
    
    # The new version's phases/sections/questions should be modifiable
    new_version.phases.each do |p|
      assert p.modifiable
      p.sections.each do |s|
        assert s.modifiable
        s.questions.each do |q|
          assert q.modifiable
        end
      end
    end
  end
  
  # GET /org/admin/templates/:id/admin_unpublish (admin_unpublish_template_path)
  # ----------------------------------------------------------
  test "unpublish a template" do
    # Should redirect user to the root path if they are not logged in!
    put admin_unpublish_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user

    family = @template.dmptemplate_id
    prior = Template.current(@user.org, family)
    
    version_the_template
    
    current = Template.current(@user.org, family)
    
    # Try to unpublish a template that is not published
    put admin_unpublish_template_path(current)
    assert_equal _('That template is not currently published.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to admin_index_template_path(@user.org)
    
    # Publish it so we can unpublish
    put admin_publish_template_path(current)
    assert_not Template.live(@user.org, family).nil?
    
    put admin_unpublish_template_path(current)
    assert_equal _('Your template is no longer published.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to admin_index_template_path(@user.org)
    
    # Make sure there are no published versions
    assert Template.live(@user.org, family).nil?
  end
end