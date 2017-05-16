require 'test_helper'

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    scaffold_template
    @section = @template.phases.first.sections.first
    
    # Get the first Org Admin
    scaffold_org_admin(@template.org)
    
    @question_format = QuestionFormat.where(option_based: false).first
  end

# TODO: The following methods SHOULD replace the old 'admin_' prefixed methods. The routes file already has
#       these defined. They are defined multiple times though and we need to clean this up! In particular
#       look at the unnamed routes after 'new_plan_phase' below. They are not named because they are duplicates.
#       We should just have:
#
# SHOULD BE:
# --------------------------------------------------
#   questions            GET    /templates/:template_id/phases/:phase_id/sections/:section_id/questions     sections#index
#                        POST   /templates/:template_id/phases/:phase_id/sections/:section_id/questions     sections#create
#   question             GET    /templates/:template_id/phases/:phase_id/section/:section_id/questions/:id  sections#show
#                        PATCH  /templates/:template_id/phases/:phase_id/section/:section_id/questions/:id  sections#update
#                        PUT    /templates/:template_id/phases/:phase_id/section/:section_id/questions/:id  sections#update
#                        DELETE /templates/:template_id/phases/:phase_id/section/:section_id/questions/:id  sections#destroy
#
# CURRENT RESULTS OF `rake routes`
# --------------------------------------------------
#   admin_create_question  POST    /org/admin/templates/questions/:id/admin_create    questions#admin_create
#   admin_update_question  PUT     /org/admin/templates/questions/:id/admin_update    questions#admin_update
#   admin_destroy_question DELETE  /org/admin/templates/questions/:id/admin_destroy   questions#admin_destroy
  
  
  # POST /org/admin/templates/questions/:id/admin_create (admin_create_question_path)
  # ----------------------------------------------------------
  test "create a new question" do
    params = {section_id: @section.id, text: 'Test Question', number: 9, question_format_id: @question_format.id}
    
    @section.phase.template.dirty = false
    @section.phase.template.save!
    
    # Should redirect user to the root path if they are not logged in!
    post admin_create_question_path(@section), {question: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    post admin_create_question_path(@section), {question: params}
    assert_response :redirect
    assert assigns(:question)
    assert_redirected_to admin_show_phase_url(id: @section.phase.id, edit: 'true', section_id: @section.id, question_id: Question.last.id)
    assert_equal _('Information was successfully created.'), flash[:notice]
    assert_equal 'Test Question', Question.last.text, "expected the record to have been created!"
    
    # Make sure that the template's dirty flag got set
    assert @section.phase.template.reload.dirty?, "expected the templates dirty flag to be true"
    
    # Invalid object
    post admin_create_question_path(@section), {question: {section_id: @section.id, text: nil}}
    assert flash[:notice].starts_with?(_('Could not create your'))
    assert_response :success
    assert assigns(:question)
    assert assigns(:section)
    assert assigns(:phase)
    assert assigns(:edit)
    assert assigns(:open)
    assert assigns(:sections)
    assert assigns(:section_id)
  end 
  
  # PUT /org/admin/templates/questions/:id/admin_update (admin_update_question_path)
  # ----------------------------------------------------------
  test "update the question" do
    params = {text: 'Question - UPDATE'}
    
    @section.phase.template.dirty = false
    @section.phase.template.save!
    
    # Should redirect user to the root path if they are not logged in!
    put admin_update_question_path(@section.questions.first), {question: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    # Valid save
    put admin_update_question_path(@section.questions.first), {question: params}
    assert_equal _('Information was successfully updated.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to admin_show_phase_url(id: @section.phase.id, edit: 'true', section_id: @section.id, question_id: @section.questions.first.id)
    assert assigns(:phase)
    assert assigns(:section)
    assert assigns(:question)
    assert_equal 'Question - UPDATE', @section.questions.first.text, "expected the record to have been updated"
    
    # Make sure that the template's dirty flag got set
    assert @section.phase.template.reload.dirty?, "expected the templates dirty flag to be true"
    
    # Invalid save
    put admin_update_question_path(@section.questions.first), {question: {text: nil}}
    assert flash[:notice].starts_with?(_('Could not update your'))
    assert_response :success
    assert assigns(:question)
    assert assigns(:section)
    assert assigns(:phase)
    assert assigns(:edit)
    assert assigns(:open)
    assert assigns(:sections)
    assert assigns(:section_id)
    assert assigns(:question_id)
  end
  
  # DELETE /org/admin/templates/questions/:id/admin_destroy (admin_destroy_question_path)
  # ----------------------------------------------------------
  test "delete the question" do
    id = @section.questions.first.id
    
    @section.phase.template.dirty = false
    @section.phase.template.save!
    
    # Should redirect user to the root path if they are not logged in!
    delete admin_destroy_question_path(id: @section.id, question_id: id)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    delete admin_destroy_question_path(id: @section.id, question_id: id)
    assert_response :redirect
    assert assigns(:phase)
    assert assigns(:section)
    assert assigns(:question)
    assert_redirected_to admin_show_phase_url(id: @section.phase.id, edit: 'true', section_id: @section.id)
    assert_equal _('Information was successfully deleted.'), flash[:notice]
    assert_raise ActiveRecord::RecordNotFound do 
      Question.find(id).nil?
    end
    
    # Make sure that the template's dirty flag got set
    assert @section.phase.template.reload.dirty?, "expected the templates dirty flag to be true"
  end
  
end