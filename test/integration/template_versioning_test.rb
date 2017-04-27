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
    put admin_publish_template_path(@template)
    @template = Template.current(@dmptemplate_id)

    assert_equal (@initial_version + 1), @template.version, "expected the version to have incremented"
    assert_not_equal @initial_id, @template.id, "expected the id to have changed"
    assert_equal @dmptemplate_id, @template.dmptemplate_id, "expected the dmptemplate_id to match"
    assert_equal false, @template.published?, "expected the new version to be unpublished"
    assert_equal @initial_title, @template.title, "expected the title to have been updated"
    
    # Change the title after its been published
    put admin_update_template_path(@template), {template: {title: "Blah blah blah"}}
    @template = Template.current(@dmptemplate_id)
    
    # Make sure that the template was versioned
    assert_equal (@initial_version + 1), @template.version, "expected the version to have incremented"
    assert_not_equal @initial_id, @template.id, "expected the id to have changed"
    assert_equal @dmptemplate_id, @template.dmptemplate_id, "expected the dmptemplate_id to match"
    assert_equal false, @template.published?, "expected the new version to be unpublished"
    assert_not_equal @initial_title, @template.title, "expected the title to have been updated"
    
    # Now retrieve the published version and verify that it is unchanged
    old = Template.live(@dmptemplate_id)
    assert_equal @initial_version, old.version, "expected the version number of the published version to be the same"
    assert_equal @initial_id, old.id, "expected the id of the published version to be the same"
    assert_equal @initial_title, old.title, "expected the title of the published version to be the same"
  end
  
  # ----------------------------------------------------------
  test 'template gets versioned when its phases are modified and it is already published' do
    @template.dirty = false
    @template.save!
    
    put admin_update_phase_path @template.phases.first, {phase: {title: 'UPDATED'}}
    @template.reload
    assert @template.dirty
  end
  
  # ----------------------------------------------------------
  test 'template gets versioned when its sections are modified and it is already published' do
    @template.dirty = false
    @template.save!
    
    put admin_update_section_path @template.phases.first.sections.first, {section: {title: 'UPDATED'}}
    @template.reload
    assert @template.dirty
  end
  
  # ----------------------------------------------------------
  test 'template gets versioned when its questions are modified and it is already published' do
    @template.dirty = false
    @template.save!
    
    put admin_update_question_path @template.phases.first.sections.first.questions.first, {question: {text: 'UPDATED'}}
    @template.reload
    assert @template.dirty
  end

  # ----------------------------------------------------------
  test 'template does NOT get versioned if its unpublished' do
    # Change the title after its been published
    put admin_update_template_path(@template), {template: {title: "Blah blah blah"}}
    @template = Template.current(@dmptemplate_id)

    assert_equal @initial_version, @template.version, "expected the version to have stayed the same"
    assert_equal @initial_id, @template.id, "expected the id to been the same"
    assert_equal @dmptemplate_id, @template.dmptemplate_id, "expected the dmptemplate_id to match"
    assert_equal false, @template.published?, "expected the version to have remained unpublished"
  end
  
  # ----------------------------------------------------------
  test 'publishing a plan unpublishes the old published plan' do
    put admin_publish_template_path(@template)
    assert_not Template.live(@dmptemplate_id).nil?
    assert_equal 1, Template.where(org: @user.org, dmptemplate_id: @dmptemplate_id, published: true).count
  end

  # ----------------------------------------------------------
  test 'unpublishing a plan makes all historical versions unpublished' do
    put admin_publish_template_path(@template)
    put admin_unpublish_template_path(@template)
    assert Template.live(@dmptemplate_id).nil?
  end
  
  # ----------------------------------------------------------
  test 'plans get attached to the appropriate template version' do
    funder_template = Template.create(org: Org.funders.first, title: 'Testing integration')

    # Sign in as the funder so that we cna publish the template
    sign_in User.find_by(org: funder_template.org)
    
    # Publish the funder template
    put admin_publish_template_path(funder_template)
    assert_response :redirect
    assert_redirected_to admin_index_template_path(funder_template.org)

    @template = Template.current(funder_template.dmptemplate_id)
    liveA = Template.live(funder_template.dmptemplate_id)
    @dmptemplate_id = @template.dmptemplate_id
    
    sign_in @user
    
    # Plan A gets attached to the template v1
    post plans_path, {plan: {funder_id: @template.org.id}}

puts "RESPONSE BODY:"    
puts @response.body
    
    assert @response.body.include?("id=\"template_id_#{liveA.id}\""), "expected the user to be presented with the published template"
    post plans_path, {template_id: liveA.id}
    planA = Plan.last
    assert_equal liveA, planA.template, "expected the latest published version to have been assigned to PlanA"
    
    # Template v2 is updated
    put admin_update_template_path(@template), {template: {title: "Blah blah blah"}}
    @template = Template.current(@dmptemplate_id)
    
    # Plan B gets attached to the template v1 because v2 is not yet published
    post plans_path, {plan: {funder_id: @template.org.id}}
    assert @response.body.include?("id=\"template_id_#{liveA.id}\""), "expected the user to be presented with the published template"
    post plans_path, {template_id: liveA.id}
    planB = Plan.last
    assert_equal liveA, planB.template, "expected the latest published version to have been assigned to PlanB"
    
    # Plan A should still be attached to v1
    assert_equal liveA, planA.template, "expected PlanA to still be attached to the original published version"
    
    # Sign back in as the funder 
    sign_in User.find_by(org: funder_template.org)
    
    # Template v2 is published
    put admin_publish_template_path(@template)
    @template = Template.current(@dmptemplate_id)
    liveB = Template.live(@dmptemplate_id)
    
    sign_in @user
    
    # Plan C gets attached to template v2
    post plans_path, {plan: {funder_id: @template.org.id}}
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
