require 'test_helper'

class TemplateVersioningTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    scaffold_template
    scaffold_org_admin(@template.org)
  end
  
  # ----------------------------------------------------------
  test 'template gets versioned when its details are updated but it is already published' do
    sign_in @user
    
    # Make sure the template starts out as unpublished. The controller will not allow changes once its published
    @template.published = false
    @template.save!
    
    initial_id = @template.id
    initial_version = @template.version
    initial_title = @template.title
    dmptemplate_id = @template.dmptemplate_id
    
    # Publish the template
    put admin_update_template_path(@template), {template: {published: "1"}}
    @template = Template.current(dmptemplate_id)

    assert_equal (initial_version + 1), @template.version, "expected the version to have incremented"
    assert_not_equal initial_id, @template.id, "expected the id to have changed"
    assert_equal dmptemplate_id, @template.dmptemplate_id, "expected the dmptemplate_id to match"
    assert_equal false, @template.published?, "expected the new version to be unpublished"
    assert_equal initial_title, @template.title, "expected the title to have been updated"
    
    # Change the title after its been published
    put admin_update_template_path(@template), {template: {title: "Blah blah blah"}}
    @template = Template.current(dmptemplate_id)
    
    # Make sure that the template was versioned
    assert_equal (initial_version + 1), @template.version, "expected the version to have incremented"
    assert_not_equal initial_id, @template.id, "expected the id to have changed"
    assert_equal dmptemplate_id, @template.dmptemplate_id, "expected the dmptemplate_id to match"
    assert_equal false, @template.published?, "expected the new version to be unpublished"
    assert_not_equal initial_title, @template.title, "expected the title to have been updated"
    
    # Now retrieve the published version and verify that it is unchanged
    old = Template.published(dmptemplate_id)
    assert_equal initial_version, old.version, "expected the version number of the published version to be the same"
    assert_equal initial_id, old.id, "expected the id of the published version to be the same"
    assert_equal initial_title, old.title, "expected the title of the published version to be the same"
  end
  
  # ----------------------------------------------------------
  test 'template gets versioned when its phases are modified and it is already published' do
    
  end
  
  # ----------------------------------------------------------
  test 'template gets versioned when its sections are modified and it is already published' do
    
  end
  
  # ----------------------------------------------------------
  test 'template gets versioned when its questions are modified and it is already published' do
    
  end
  
  # ----------------------------------------------------------
  test 'template gets versioned when its details are updated but it is already published' do
    sign_in @user
    
    # Make sure the template starts out as unpublished. The controller will not allow changes once its published
    @template.published = false
    @template.save!
    
    initial_id = @template.id
    initial_version = @template.version
    initial_title = @template.title
    dmptemplate_id = @template.dmptemplate_id
    
    # Publish the template
    put admin_update_template_path(@template), {template: {published: "1"}}
    @template = Template.current(dmptemplate_id)

    assert_equal (initial_version + 1), @template.version, "expected the version to have incremented"
    assert_not_equal initial_id, @template.id, "expected the id to have changed"
    assert_equal dmptemplate_id, @template.dmptemplate_id, "expected the dmptemplate_id to match"
    assert_equal false, @template.published?, "expected the new version to be unpublished"
    assert_equal initial_title, @template.title, "expected the title to have been updated"
    
    # Change the title after its been published
    put admin_update_template_path(@template), {template: {title: "Blah blah blah"}}
    @template = Template.current(dmptemplate_id)
    
    # Make sure that the template was versioned
    assert_equal (initial_version + 1), @template.version, "expected the version to have incremented"
    assert_not_equal initial_id, @template.id, "expected the id to have changed"
    assert_equal dmptemplate_id, @template.dmptemplate_id, "expected the dmptemplate_id to match"
    assert_equal false, @template.published?, "expected the new version to be unpublished"
    assert_not_equal initial_title, @template.title, "expected the title to have been updated"
    
    # Now retrieve the published version and verify that it is unchanged
    old = Template.published(dmptemplate_id)
    assert_equal initial_version, old.version, "expected the version number of the published version to be the same"
    assert_equal initial_id, old.id, "expected the id of the published version to be the same"
    assert_equal initial_title, old.title, "expected the title of the published version to be the same"
  end
  
  # ----------------------------------------------------------
  test 'template does NOT get versioned if its un-published' do
    sign_in @user
    
    # Make sure the template starts out as unpublished. 
    @template.published = false
    @template.save!
    
    initial_id = @template.id
    initial_version = @template.version
    initial_title = @template.title
    dmptemplate_id = @template.dmptemplate_id
    
    # Change the title after its been published
    put admin_update_template_path(@template), {template: {title: "Blah blah blah"}}
    @template = Template.current(dmptemplate_id)
    
    # Now retrieve the current version and verify that it is unchanged
    current = Template.current(dmptemplate_id)
    assert_not old.published?, "expected the old version to have become unpublished"
    assert_not_equal current.id, old.id, "expected the published version id to have changed"
  end
  
  
  # ----------------------------------------------------------
  test 'plans get attached to the appropriate template version' do
=begin
    # Template is published 
    # Plan A gets attached to the template v1
    
    # Template v1 is updated and gets versioned to v2
    
    # Plan B gets attached to the template v1 because v2 is not yet published
    # Plan A is still attached to v1
    
    # Template v2 is published
    
    # Plan C gets attached to template v2
    # Plan A and B are still attached to v1
=end
  end
end
