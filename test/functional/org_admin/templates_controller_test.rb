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

  test "Org admin sees the correct templates on the templates page" do
    init_templates
    sign_in @org_admin
    get org_admin_templates_path
    
    verify_all_templates_table(@org_admin)
    verify_own_templates_table(@org_admin)
    verify_funder_templates_table(@org_admin)
  end
    
  test "Funder admin sees the correct templates on the templates page" do
    init_templates
    sign_in @funder_admin
    get org_admin_templates_path
    
    verify_all_templates_table(@funder_admin)
    verify_own_templates_table(@funder_admin)
    verify_funder_templates_table(@funder_admin)
  end
  
  test "Super admin sees the correct templates on the templates page" do
    init_templates
    sign_in @super_admin
    get org_admin_templates_path
    
    verify_all_templates_table(@super_admin)
    verify_own_templates_table(@super_admin)
    verify_funder_templates_table(@super_admin)
  end
  
  test "Predefined scopes correctly filter results on all templates table" do
    init_templates
    sign_in @super_admin
    get org_admin_templates_path
    
    verify_all_templates_table(@super_admin)
    
    published = Template.latest_version.where(published: true, customization_of: nil)
    unpublished = Template.latest_version.where(published: false, customization_of: nil)
    verify_templates_table_scoping(all_org_admin_templates_path('ALL'), '#all-templates', published, unpublished)
  end
  
  test "Predefined scopes correctly filter results on own templates table" do
    init_templates
    sign_in @org_admin
    get org_admin_templates_path
    
    verify_all_templates_table(@org_admin)
    
    published = Template.get_latest_template_versions(@org_admin.org).where(published: true, customization_of: nil)
    unpublished = Template.get_latest_template_versions(@org_admin.org).where(published: false, customization_of: nil)
    verify_templates_table_scoping(orgs_org_admin_templates_path('ALL'), '#organisation-templates', published, unpublished)
  end

  test "Predefined scopes correctly filter results on customizable templates table" do
    init_templates
    sign_in @org_admin
    get org_admin_templates_path
    
    verify_all_templates_table(@org_admin)
    
    published = Template.where(title: 'UOS customization of Default template')
    unpublished = Template.where('published = 1 AND visibility = 1 AND is_default = 0')
    verify_templates_table_scoping(funders_org_admin_templates_path('ALL'), '#funders-templates', published, unpublished)
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

  test 'get templates#edit returns redirect (found) when template is current and is published' do
    @template.dirty = false
    @template.published = true
    @template.save
    sign_in @user
    get(edit_org_admin_template_path(@template.id))
    assert_response(:redirect)
  end

  test 'get templates#edit returns ok when template is current and is NOT published' do
    sign_in @user
    get(edit_org_admin_template_path(@template.id))
    assert_response(:ok)
    assert_nil(flash[:notice])
  end

  test 'get templates#edit returns ok with flash notice when template is not current' do
    new_version = Template.deep_copy(@template)
    new_version.version = (@template.version + 1)
    new_version.save
    sign_in @user
    get(edit_org_admin_template_path(@template.id))
    assert_response(:ok)
    assert_equal(_('You are viewing a historical version of this template. You will not be able to make changes.'), flash[:notice])
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
    assert_redirected_to "#{org_admin_templates_path}#organisation-templates"

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

    # Publish the current template
    get publish_org_admin_template_path(current)
    assert_equal _('Your template has been published and is now available to users.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to "#{org_admin_templates_path}#organisation-templates"
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
    assert_redirected_to "#{org_admin_templates_path}#organisation-templates"

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

  private
  def init_templates
    # First clear out any existing templates
    Template.all.each do |template|
      template.destroy!
    end
    
    @super_admin = User.find_by(email: 'super_admin@example.com')
    @org_admin = User.find_by(email: 'org_admin@example.com')
    @funder_admin = User.find_by(email: 'funder_admin@example.com')
    
    default_org = Org.find_by(org_type: 4)
    funder_org = Org.find_by(org_type: 2)
    institution_org = Org.find_by(org_type: 1)
    other_org = Org.create!(name: 'Another Org', abbreviation: 'BLAH', org_type: 3, links: {"org":[]})
    
    params = [{ title: 'Default template', org: default_org, migrated: false, dmptemplate_id: '00000100', published: true, version: 0, visibility: Template.visibilities[:publicly_visible], is_default: true },
              { title: 'UOS published A', org: institution_org, migrated: false, dmptemplate_id: '00000099', published: true, version: 0, visibility: Template.visibilities[:organisationally_visible], is_default: false },
              { title: 'UOS published B', org: institution_org, migrated: false, dmptemplate_id: '00000098', published: true, version: 0, visibility: Template.visibilities[:organisationally_visible], is_default: false },
              { title: 'UOS unpublished C', org: institution_org, migrated: false, dmptemplate_id: '00000097', published: false, version: 0, visibility: Template.visibilities[:organisationally_visible], is_default: false },
              { title: 'UOS unpublished Dv0', org: institution_org, migrated: false, dmptemplate_id: '00000096', published: false, version: 0, visibility: Template.visibilities[:organisationally_visible], is_default: false },
              { title: 'UOS published Dv1', org: institution_org, migrated: false, dmptemplate_id: '00000096', published: true, version: 1, visibility: Template.visibilities[:organisationally_visible], is_default: false },
              { title: 'UOS published Ev0', org: institution_org, migrated: false, dmptemplate_id: '00000095', published: true, version: 0, visibility: Template.visibilities[:organisationally_visible], is_default: false },
              { title: 'UOS unpublished Ev1', org: institution_org, migrated: false, dmptemplate_id: '00000095', published: false, version: 1, visibility: Template.visibilities[:organisationally_visible], is_default: false },
              { title: 'BLAH internal published A', org: other_org, migrated: false, dmptemplate_id: '00000079', published: true, version: 0, visibility: Template.visibilities[:organisationally_visible], is_default: false },
              { title: 'BLAH public published B', org: other_org, migrated: false, dmptemplate_id: '00000078', published: true, version: 0, visibility: Template.visibilities[:publicly_visible], is_default: false },
              { title: 'Funder public published A', org: funder_org, migrated: false, dmptemplate_id: '00000089', published: true, version: 0, visibility: Template.visibilities[:publicly_visible], is_default: false },
              { title: 'Funder internal published B', org: funder_org, migrated: false, dmptemplate_id: '00000088', published: true, version: 0, visibility: Template.visibilities[:organisationally_visible], is_default: false },
              { title: 'Funder internal unpublished B', org: funder_org, migrated: false, dmptemplate_id: '00000088', published: false, version: 1, visibility: Template.visibilities[:organisationally_visible], is_default: false },
              { title: 'Funder public unpublished C', org: funder_org, migrated: false, dmptemplate_id: '00000087', published: false, version: 0, visibility: Template.visibilities[:publicly_visible], is_default: false },
              { title: 'Funder public unpublished Dv0', org: funder_org, migrated: false, dmptemplate_id: '00000086', published: false, version: 0, visibility: Template.visibilities[:publicly_visible], is_default: false },
              { title: 'Funder public published Dv1', org: funder_org, migrated: false, dmptemplate_id: '00000086', published: true, version: 1, visibility: Template.visibilities[:publicly_visible], is_default: false },
              { title: 'Funder public published Ev0', org: funder_org, migrated: false, dmptemplate_id: '00000085', published: true, version: 0, visibility: Template.visibilities[:publicly_visible], is_default: false },
              { title: 'Funder public unpublished Ev1', org: funder_org, migrated: false, dmptemplate_id: '00000085', published: false, version: 1, visibility: Template.visibilities[:publicly_visible], is_default: false }]
    
    params.each do |hash|
      begin
        template = Template.new(hash)
        template.save!
        # Template's have default values when created, so override those defaults
        template.update_attributes!(published: hash[:published], visibility: hash[:visibility], is_default: hash[:is_default], dmptemplate_id: hash[:dmptemplate_id])
        
        if template.is_default?
          cust = Template.create!({ title: 'UOS customization of Default template', org: institution_org, migrated: false, version: 0})
          cust.update_attributes(published: true, customization_of: template.dmptemplate_id, visibility: Template.visibilities[:organisationally_visible])
        elsif template.title == 'Funder public published A'
          cust = Template.create!({ title: 'UOS customization of Funder public published A', org: institution_org, migrated: false, version: 0})
          cust.update_attributes(published: false, customization_of: template.dmptemplate_id, visibility: Template.visibilities[:organisationally_visible])
        end
      rescue ActiveRecord::RecordInvalid
        puts "EXCEPTION: #{template.errors.collect{ |e, m| "#{e}: #{m}" }.join(', ')}"
      end 
    end
  end
  
  def verify_all_templates_table(user)
    if user.can_super_admin?
      assert_select "#all-templates table tbody", true, "expected a super admin to be able to see the all templates table"
    else
      assert_select "#all-templates table tbody", false, "expected a non-super admin to NOT see the all templates table"
    end
  end
  
  def verify_own_templates_table(user)
    assert_select "#organisation-templates table tbody" do |el|
      templates = Template.where(org: user.org, customization_of: nil)
      
      # Org Admins (funder or non-funder)
      if user.can_org_admin?
        # An Org Admin (for a non-funder Org) should only see their current templates in the own templates table
        templates.each do |template|
          # Expect to see the most current version of organisational templates
          current = Template.current(template.dmptemplate_id)
          if template == current
            assert el.to_s.include?(template.title), "expected #{user.email}'s own templates table to have the institutional template: '#{template.title}'"
          else
            assert_not el.to_s.include?(template.title), "expected #{user.email}'s own templates table to NOT have an older version of an the org's template: '#{template.title}'"
          end
        end

        # Expect to see no templates for other orgs in the own templates table
        Template.where.not(id: templates.collect(&:id)).each do |template|
          assert_not el.to_s.include?(template.title), " expected #{user.email}'s own templates table to NOT have: '#{template.title}'"
        end

        # Expect the funder templates table to contain NO 'Edit/Publish menus
        assert_not el.to_s.include?('Customise'), "expected #{user.email}'s own templates table to NOT contain any of the Customization menu items in the funder templates table"
      end
    end
  end
  
  def verify_funder_templates_table(user)
    assert_select "#funder-templates table tbody" do |el|
      # An Org Admin should see all of the funder/default templates (except ones that belong to their org)
      templates = Template.where("(org_id IN (?) OR is_default = ?) AND org_id != ?", Org.where(org_type: [2,3]).collect(&:id), true, user.org.id)
      if user.can_org_admin?
        templates.each do |template|
          # Expect to only see published public templates
          if template.publicly_visible? && template.published?
            assert el.to_s.include?(template.title), "expected #{user.email}'s customizable table to have the funder (or default) template: '#{template.title}'" 
          else
            assert_not el.to_s.include?(template.title), "expected #{user.email}'s customizable table to NOT have the unpublished/non-public funder template: '#{template.title}' (from org: #{template.org.abbreviation})"
          end
        end

        # Expect to see only the current org's customizations
        Template.where.not(id: templates.collect(&:id)).each do |template|
          if template.customization_of.nil?
            assert_not el.to_s.include?(template.title), "expected #{user.email}'s customizable table to NOT have the template from a non-funder org: '#{template.title}'"
          else
            if template.org == user.org
              assert el.to_s.include?(template.title), "expected #{user.email}'s customizable table to have their own customization: '#{template.title}'" 
            else
              assert_not el.to_s.include?(template.title), "expected #{user.email}'s customizable table to NOT have a customization from another organisation: '#{template.title}'"
            end
          end
        end
      end
    end
  end
  
  def verify_templates_table_scoping(path, selector, published, unpublished)
    get "#{path}?scope=published"
    assert_select "table tbody" do |el|
      published.each do |template|
        assert el.to_s.include?(template.title), "expected to see '#{template.title}' in #{selector} after clicking the 'published' predefined scope"
      end
      unpublished.each do |template|
        assert_not el.to_s.include?(template.title), "expected to NOT see '#{template.title}' in #{selector} after clicking the 'published' predefined scope"
      end
    end
    
    get "#{path}?scope=unpublished"
    assert_select "table tbody" do |el|
      published.each do |template|
        assert_not el.to_s.include?(template.title), "expected to NOT see '#{template.title}' in #{selector} after clicking the 'unpublished' predefined scope"
      end
      unpublished.each do |template|
        assert el.to_s.include?(template.title), "expected to see '#{template.title}' #{selector} after clicking the 'unpublished' predefined scope"
      end
    end
    
    get "#{path}?scope=all"
    assert_select "table tbody" do |el|
      published.each do |template|
        assert el.to_s.include?(template.title), "expected to see '#{template.title}' in #{selector} after clicking the 'all' predefined scope"
      end
      unpublished.each do |template|
        assert el.to_s.include?(template.title), "expected to see '#{template.title}' in #{selector} after clicking the 'all' predefined scope"
      end
    end
  end
end
