require 'test_helper'

class SuggestedAnswersControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    @question = SuggestedAnswer.first.question
    
    # Get the first Org Admin
    scaffold_org_admin(@question.section.phase.template.org)
  end

# TODO: The following methods SHOULD replace the old 'admin_' prefixed methods. The routes file already has
#       these defined. They are defined multiple times though and we need to clean this up! In particular
#       look at the unnamed routes after 'new_plan_phase' below. They are not named because they are duplicates.
#       We should just have:
#
# SHOULD BE:
# --------------------------------------------------
#   suggested_answers    GET    /templates/:template_id/phases/:phase_id/sections/:section_id/questions/:id     sections#index
#                        POST   /templates/:template_id/phases/:phase_id/sections/:section_id/questions/:id     sections#create
#   suggested_answer     GET    /templates/:template_id/phases/:phase_id/sections/:section_id/questions/:question_id/suggested_answer/:id  sections#show
#                        PATCH  /templates/:template_id/phases/:phase_id/section/:section_id/questions/:question_id/suggested_answer/:id  sections#update
#                        PUT    /templates/:template_id/phases/:phase_id/section/:section_id/questions/:question_id/suggested_answer/:id  sections#update
#                        DELETE /templates/:template_id/phases/:phase_id/section/:section_id/questions/:question_id/suggested_answer/:id  sections#destroy
#
# CURRENT RESULTS OF `rake routes`
# --------------------------------------------------
#   admin_create_suggested_answer  POST   /org/admin/templates/suggested_answers/:id/admin_create suggested_answers#admin_create
#   admin_update_suggested_answer  PUT    /org/admin/templates/suggested_answers/:id/admin_update suggested_answers#admin_update
#   admin_destroy_suggested_answer DELETE /org/admin/templates/suggested_answers/:id/admin_destroy suggested_answers#admin_destroy
  
  
  
  # POST /org/admin/templates/suggested_answers/:id/admin_create (admin_create_suggested_answer_path)
  # ----------------------------------------------------------
  test "create a new section" do
    params = {org_id: @user.org.id, question_id: @question.id, text: "Here's a suggestion"}
    
    # Should redirect user to the root path if they are not logged in!
    post admin_create_suggested_answer_path(@question.id), {suggested_answer: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    post admin_create_suggested_answer_path(@question.id), {suggested_answer: params}
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?edit=true&question_id=#{@question.id}&section_id=#{@question.section.id}"
    assert_equal _('Information was successfully created.'), flash[:notice]
    assert_equal "Here's a suggestion", SuggestedAnswer.last.text, "expected the record to have been created!"
    assert assigns(:suggested_answer)
    
    # Invalid object
    post admin_create_suggested_answer_path(@question.id), {suggested_answer: {question_id: @question.id}}
    assert flash[:notice].starts_with?(_('Could not create your'))
    assert_response :success
    assert assigns(:suggested_answer)
  end 
  
  # PUT /org/admin/templates/suggested_answers/:id/admin_update (admin_update_suggested_answer_path)
  # ----------------------------------------------------------
  test "update the section" do
    params = {text: 'UPDATE'}
    
    # Should redirect user to the root path if they are not logged in!
    put admin_update_suggested_answer_path(SuggestedAnswer.first), {suggested_answer: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user

    # Valid save
    put admin_update_suggested_answer_path(SuggestedAnswer.first), {suggested_answer: params}
    assert_equal _('Information was successfully updated.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?edit=true&question_id=#{@question.id}&section_id=#{@question.section.id}"
    assert assigns(:suggested_answer)
    assert assigns(:question)
    assert assigns(:section)
    assert assigns(:phase)
    assert_equal 'UPDATE', SuggestedAnswer.first.text, "expected the record to have been updated"
    
# TODO: We need to add in validation checks on the model and reactivate this test
    # Invalid save
#    put admin_update_suggested_answer_path(SuggestedAnswer.first), {suggested_answer: {text: nil}}
#    assert flash[:notice].starts_with?(_('Could not update your'))
#    assert_response :success
#    assert assigns(:suggested_answer)
#    assert assigns(:question)
#    assert assigns(:section)
#    assert assigns(:phase)
  end
  
  # DELETE /org/admin/templates/suggested_answers/:id/admin_destroy (admin_destroy_suggested_answer_path)
  # ----------------------------------------------------------
  test "delete the section" do
    id = SuggestedAnswer.first.id
    # Should redirect user to the root path if they are not logged in!
    delete admin_destroy_suggested_answer_path(id: id)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    delete admin_destroy_suggested_answer_path(id: id)
    assert_equal _('Information was successfully deleted.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?edit=true&section_id=#{@question.section.id}"
    assert assigns(:question)
    assert assigns(:section)
    assert assigns(:phase)
    assert_raise ActiveRecord::RecordNotFound do 
      SuggestedAnswer.find(id).nil?
    end
  end
  
end