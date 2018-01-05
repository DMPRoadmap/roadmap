require 'test_helper'

class AnnotationsControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  setup do
    @question = Annotation.first.question
    
    # Get the first Org Admin
    scaffold_org_admin(@question.section.phase.template.org)

    # clear the existing annotations
    @question.annotations.where(org: @user.org).each do |annotation|
      annotation.destroy!
    end
        
    @create_hash = {question_id: @question.id, example_answer_text: "New example", guidance_text: "New guidance"}
    @example_answer_qry = {question: @question, org: @user.org, type: Annotation.types[:example_answer]}
    @guidance_qry = {question: @question, org: @user.org, type: Annotation.types[:guidance]}
  end

  test "cannot create/update if not logged in" do
    # Should redirect user to the root path if they are not logged in!
    put admin_update_annotation_path(id: @question.section.phase.id), @create_hash
    assert_unauthorized_redirect_to_root_path
  end
  
  test "can create example answer and guidance at the same time" do
    sign_in @user
    put admin_update_annotation_path(id: @question.section.phase.id), @create_hash
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?section_id=#{@question.section.id}"
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('example answer') && flash[:notice].include?('guidance')
    assert_equal 'New example', Annotation.find_by(@example_answer_qry).text, "expected example answer to have been created."
    assert_equal 'New guidance', Annotation.find_by(@guidance_qry).text, "expected guidance to have been created."
  end
  test "can create example answer without a guidance" do
    sign_in @user
    put admin_update_annotation_path(id: @question.section.phase.id), {question_id: @question.id, example_answer_text: "New example"}
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('updated')
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?section_id=#{@question.section.id}"
    assert_equal 'New example', Annotation.find_by(@example_answer_qry).text, "expected example answer to have been created."
    assert Annotation.find_by(@guidance_qry).nil?, "expected no guidance to have been created."
  end
  test "can create guidance without an example answer" do
    sign_in @user
    put admin_update_annotation_path(id: @question.section.phase.id), {question_id: @question.id, guidance_text: "New guidance"}
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('updated')
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?section_id=#{@question.section.id}"
    assert Annotation.find_by(@example_answer_qry).nil?, "expected no example answer to have been created."
    assert_equal 'New guidance', Annotation.find_by(@guidance_qry).text, "expected guidance to have been created."
  end
  
  test "can update example answer and guidance at the same time" do
    put admin_update_annotation_path(id: @question.section.phase.id), @create_hash
    sign_in @user
    put admin_update_annotation_path(id: @question.section.phase.id), {question_id: @question.id, example_answer_text: "Updated example", guidance_text: "Updated guidance"}
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('updated')
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?section_id=#{@question.section.id}"
    assert_equal 'Updated example', Annotation.find_by(@example_answer_qry).text, "expected example answer to have been updated."
    assert_equal 'Updated guidance', Annotation.find_by(@guidance_qry).text, "expected guidance to have been updated."
  end
  test "can remove example answer by not submitting it during save" do
    put admin_update_annotation_path(id: @question.section.phase.id), @create_hash
    sign_in @user
    put admin_update_annotation_path(id: @question.section.phase.id), {question_id: @question.id, guidance_text: "Updated guidance"}
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('updated')
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?section_id=#{@question.section.id}"
    assert Annotation.find_by(@example_answer_qry).nil?, "expected example answer to have been removed."
    assert_equal 'Updated guidance', Annotation.find_by(@guidance_qry).text, "expected guidance to have been updated."
  end
  test "can remove guidance by not submitting it during save" do
    put admin_update_annotation_path(id: @question.section.phase.id), @create_hash
    sign_in @user
    put admin_update_annotation_path(id: @question.section.phase.id), {question_id: @question.id, example_answer_text: "Updated example"}
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('updated')
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?section_id=#{@question.section.id}"
    assert_equal 'Updated example', Annotation.find_by(@example_answer_qry).text, "expected example answer to have been updated."
    assert Annotation.find_by(@guidance_qry).nil?, "expected guidance to have been removed."
  end
  
  test "can delete a specific annotation" do
    sign_in @user
    put admin_update_annotation_path(id: @question.section.phase.id), @create_hash
    delete admin_destroy_annotation_path(Annotation.find_by(@example_answer_qry))
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('deleted')
    assert_response :redirect
    assert_redirected_to "#{admin_show_phase_path(@question.section.phase.id)}?section_id=#{@question.section.id}"
    assert Annotation.find_by(@example_answer_qry).nil?
    assert_equal 'New guidance', Annotation.find_by(@guidance_qry).text, "expected guidance to have been unchanged."
  end
end