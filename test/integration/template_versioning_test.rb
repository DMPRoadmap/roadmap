require 'test_helper'

class TemplateVersioningTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    scaffold_template
    scaffold_org_admin(@template.org)
    
    sign_in @user
    
    # Make sure the template starts out as unpublished. The controller will not allow changes once its published
    @template.published = false
    @template.save!
    
    @initial_id = @template.id
    @initial_version = @template.version
    @initial_title = @template.title
    @dmptemplate_id = @template.dmptemplate_id
  end
  
  # ----------------------------------------------------------
  test 'template gets versioned when its details are updated but it is already published' do
    # Publish the template
    put admin_update_template_path(@template), {template: {published: "1"}}
    @template = Template.current(@user.org, @dmptemplate_id)

    assert_equal (@initial_version + 1), @template.version, "expected the version to have incremented"
    assert_not_equal @initial_id, @template.id, "expected the id to have changed"
    assert_equal @dmptemplate_id, @template.dmptemplate_id, "expected the dmptemplate_id to match"
    assert_equal false, @template.published?, "expected the new version to be unpublished"
    assert_equal @initial_title, @template.title, "expected the title to have been updated"
    
    # Change the title after its been published
    put admin_update_template_path(@template), {template: {title: "Blah blah blah"}}
    @template = Template.current(@user.org, @dmptemplate_id)
    
    # Make sure that the template was versioned
    assert_equal (@initial_version + 1), @template.version, "expected the version to have incremented"
    assert_not_equal @initial_id, @template.id, "expected the id to have changed"
    assert_equal @dmptemplate_id, @template.dmptemplate_id, "expected the dmptemplate_id to match"
    assert_equal false, @template.published?, "expected the new version to be unpublished"
    assert_not_equal @initial_title, @template.title, "expected the title to have been updated"
    
    # Now retrieve the published version and verify that it is unchanged
    old = Template.live(@user.org, @dmptemplate_id)
    assert_equal @initial_version, old.version, "expected the version number of the published version to be the same"
    assert_equal @initial_id, old.id, "expected the id of the published version to be the same"
    assert_equal @initial_title, old.title, "expected the title of the published version to be the same"
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
  test 'template does NOT get versioned if its un-published' do
    # Change the title after its been published
    put admin_update_template_path(@template), {template: {title: "Blah blah blah"}}
    @template = Template.current(@user.org, @dmptemplate_id)

    assert_equal @initial_version, @template.version, "expected the version to have stayed the same"
    assert_equal @initial_id, @template.id, "expected the id to been the same"
    assert_equal @dmptemplate_id, @template.dmptemplate_id, "expected the dmptemplate_id to match"
    assert_equal false, @template.published?, "expected the version to have remained unpublished"
  end
  
  
  # ----------------------------------------------------------
  test 'plans get attached to the appropriate template version' do
    # Template is published 
    put admin_update_template_path(@template), {template: {published: "1"}}
    @template = Template.current(@user.org, @dmptemplate_id)
    liveA = Template.live(@user.org, @dmptemplate_id)
    
    # Plan A gets attached to the template v1
    post plans_path, {plan: {funder_id: @user.org_id}}
    assert @response.body.include?("id=\"template_id_#{liveA.id}\""), "expected the user to be presented with the published template"
    post plans_path, {template_id: liveA.id}
    planA = Plan.last
    assert_equal liveA, planA.template, "expected the latest published version to have been assigned to PlanA"
    
    # Template v1 is updated and gets versioned to v2
    put admin_update_template_path(@template), {template: {title: "Blah blah blah"}}
    @template = Template.current(@user.org, @dmptemplate_id)
    
    # Plan B gets attached to the template v1 because v2 is not yet published
    post plans_path, {plan: {funder_id: @user.org_id}}
    assert @response.body.include?("id=\"template_id_#{liveA.id}\""), "expected the user to be presented with the published template"
    post plans_path, {template_id: liveA.id}
    planB = Plan.last
    assert_equal liveA, planB.template, "expected the latest published version to have been assigned to PlanB"
    
    # Plan A should still be attached to v1
    assert_equal liveA, planA.template, "expected PlanA to still be attached to the original published version"
    
    # Template v2 is published
    put admin_update_template_path(@template), {template: {published: "1"}}
    @template = Template.current(@user.org, @dmptemplate_id)
    liveB = Template.live(@user.org, @dmptemplate_id)
    
    # Plan C gets attached to template v2
    post plans_path, {plan: {funder_id: @user.org_id}}
    assert_not @response.body.include?("id=\"template_id_#{liveA.id}\""), "expected the user to NOT be presented with the OLD published template"
    assert @response.body.include?("id=\"template_id_#{liveB.id}\""), "expected the user to be presented with the published template"
    post plans_path, {template_id: liveB.id}
    planC = Plan.last
    assert_equal liveB, planC.template, "expected the latest published version to have been assigned to PlanA"
    
    # Plan A and B are still attached to v1
    assert_equal liveA, planA.template, "expected PlanA to still be attached to the original published version"
    assert_equal liveA, planB.template, "expected PlanB to still be attached to the original published version"
  end
end
