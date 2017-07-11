require 'test_helper'

class AnnotationsControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  setup do
    @question = Annotation.first.question

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



  # POST /org/admin/templates/suggested_answers/:id/admin_create (admin_create_annotation_path)
  # ----------------------------------------------------------
  test "create a new annotation" do
    params_guid = {question_id: @question.id, guidance_text: "some guidance text"}
    params_example = {question_id: @question.id, example_answer_text: "example answer text"}
    params_both = {question_id: @question.id,  example_answer_text: "example answer text", guidance_text: "some guidance text"}

    # Should redirect user to the root path if they are not logged in!
    post admin_create_annotation_path(id: Annotation.first.id), params_both
    assert_unauthorized_redirect_to_root_path

    sign_in @user

    # both
    post admin_create_annotation_path(id: Annotation.first.id), params_both
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?edit=true&question_id=#{@question.id}&section_id=#{@question.section.id}"
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('created')
    assert_equal "some guidance text", Annotation.last.text, "expected the guidance to have been created!"
    assert_equal "example answer text", Annotation.all[-2].text, "expected the example answer to have been created"
    # just an example answer
    post admin_create_annotation_path(id: Annotation.first.id), params_example
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?edit=true&question_id=#{@question.id}&section_id=#{@question.section.id}"
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('created')
    assert_equal "example answer text", Annotation.last.text, "expected the record to have been created!"
    # just some guidance
    post admin_create_annotation_path(id: Annotation.first.id), params_guid
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?edit=true&question_id=#{@question.id}&section_id=#{@question.section.id}"
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('created')
    assert_equal "some guidance text", Annotation.last.text, "expected the record to have been created!"

  end

  # PUT /org/admin/templates/suggested_answers/:id/admin_update (admin_update_suggested_answer_path)
  # ----------------------------------------------------------
  test "update the annotation" do
    q = Annotation.first.question
    params_guid = {question_id: q.id, guidance_id: Annotation.first.id ,guidance_text: 'UPDATE'}
    params_example = {question_id: q.id, example_answer_id: Annotation.first.id, example_answer_text: 'UPDATE'}
    params_both = {question_id: q.id, guidance_id: Annotation.first.id ,guidance_text: 'gUPDATE',example_answer_id: Annotation.last.id, example_answer_text: 'eUPDATE'}

    # Should redirect user to the root path if they are not logged in!
    put admin_update_annotation_path(id: Annotation.first.id), params_guid
    assert_unauthorized_redirect_to_root_path

    sign_in @user

    # Valid save for guidance only
    put admin_update_annotation_path(id: Annotation.first.id), params_guid
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('saved')
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?edit=true&question_id=#{@question.id}&section_id=#{@question.section.id}"
    assert_equal 'UPDATE', Annotation.first.text, "expected the record to have been updated"
    # valid save for example only
    put admin_update_annotation_path(id: Annotation.first.id), params_example
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('saved')
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?edit=true&question_id=#{@question.id}&section_id=#{@question.section.id}"
    assert_equal 'UPDATE', Annotation.first.text, "expected the record to have been updated"
    # valid save for both example answer and guidance
    put admin_update_annotation_path(id: Annotation.first.id), params_both
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('saved')
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?edit=true&question_id=#{@question.id}&section_id=#{@question.section.id}"
    assert_equal 'gUPDATE', Annotation.first.text, "expected the record to have been updated"
    assert_equal 'eUPDATE', Annotation.last.text, "expected the record to have been updated"

  end

  # DELETE /org/admin/templates/suggested_answers/:id/admin_destroy (admin_destroy_suggested_answer_path)
  # ----------------------------------------------------------
  test "delete the section" do
    id = Annotation.first.id
    # Should redirect user to the root path if they are not logged in!
    delete admin_destroy_annotation_path(id: id)
    assert_unauthorized_redirect_to_root_path

    sign_in @user

    delete admin_destroy_annotation_path(id: id)
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('deleted')
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?edit=true&section_id=#{@question.section.id}"
    assert assigns(:question)
    assert assigns(:section)
    assert assigns(:phase)
    assert_raise ActiveRecord::RecordNotFound do
      Annotation.find(id).nil?
    end
  end

end