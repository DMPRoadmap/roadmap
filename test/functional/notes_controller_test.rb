require 'test_helper'

class NotesControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    @user = User.last
    
    scaffold_plan
    
    @question = Question.create(text: 'Answer Testing', number: 9, 
                                section: @plan.template.phases.first.sections.first,
                                question_format: QuestionFormat.find_by(option_based: false))
                               
    @answer = Answer.create(user: @user, plan: @plan, question: @question, text: 'Testing')
    
    @note = Note.create(user: @user, plan: @plan, answer: @answer, question: @question, archived: false,
                        text: 'Test Note')
  end

# TODO: The following methods SHOULD probably be restful
#
# SHOULD BE:
# --------------------------------------------------
#   notes                GET    /answers/:answer_id/notes            notes#index
#                        POST   /answers/:answer_id/notes            notes#create
#   note                 GET    /answers/:answer_id/notes/:id        notes#show
#                        PATCH  /answers/:answer_id/notes/:id        notes#update
#                        PUT    /answers/:answer_id/notes/:id        notes#update
#                        DELETE /answers/:answer_id/notes/:id        notes#destroy
#
# CURRENT RESULTS OF `rake routes`
# --------------------------------------------------
#   archive_note        PATCH    /notes/:id/archive              notes#archive
#   notes               POST     /notes                          notes#create
#   note                PATCH    /notes/:id                      notes#update
#                       PUT      /notes/:id                      notes#update
  
  
  
  # POST /notes (notes_path)
  # ----------------------------------------------------------
  test "create a new note" do
    params = {user_id: @user.id, answer_id: @answer.id, plan_id: @plan.id, question_id: @question.id, 
              "#{@question.id}new_note_text": 'Test Note'}
    
    # Should redirect user to the root path if they are not logged in!
    post notes_path, {new_note: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    post notes_path, {new_note: params}, {'ACCEPT': 'text/javascript'}
    assert_response :success
    assert assigns(:note)
    assert assigns(:plan)
    assert assigns(:answer)
    assert assigns(:question)
    assert assigns(:notice)
    assert assigns(:num_notes)
# TODO: We don't appear to be displaying the success/failure notice anywhere in the js.erb
    #assert_select '.welcome-message h2', _('Comment was successfully created.')
    assert_equal 'Test Note', Note.last.text, 'Expected the note to have been created'
    
    # No Answer
    post notes_path, {new_note: {user_id: @user.id, plan_id: @plan.id, question_id: @question.id, 
                                  "#{@question.id}new_note_text": 'Test Note no Answer'}}, {'ACCEPT': 'text/javascript'}
    assert_response :success
    assert assigns(:note)
    assert assigns(:plan)
    assert assigns(:answer)
    assert assigns(:question)
    assert assigns(:notice)
    assert assigns(:num_notes)
# TODO: We don't appear to be displaying the success/failure notice anywhere in the js.erb
    #assert_select '.welcome-message h2', _('Comment was successfully created.')
# TODO: expected the new note to have been added :/ 
    #assert_equal 'Test Note no Answer', Note.last.text, 'Expected the note to have been created even if there was no answer'
    
    # Invalid object
    post notes_path, {new_note: {user_id: @user.id, answer_id: @answer.id, plan_id: @plan.id, 
                                                  question_id: @question.id}}, {'ACCEPT': 'text/javascript'}
    assert_response :success
    assert assigns(:note)
    assert assigns(:plan)
    assert assigns(:answer)
    assert assigns(:question)
    assert assigns(:notice)
    assert assigns(:num_notes)
# TODO: We don't appear to be displaying the success/failure notice anywhere in the js.erb
    #assert_select '.welcome-message h2', _('Unable to save your changes.')
  end 
  
  # PUT /notes/:id (note_path)
  # ----------------------------------------------------------
  test "update the note" do
    # Should redirect user to the root path if they are not logged in!
    put note_path(@note), {note: {id: @note.id}, "#{@question.id}new_note_text": 'Test Note'}, {'ACCEPT': 'text/javascript'}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user

    # Valid save
    put note_path(@note), {note: {id: @note.id}, "#{@question.id}new_note_text": 'Test Note'}, {'ACCEPT': 'text/javascript'}
    assert_response :success
    assert assigns(:note)
    assert assigns(:plan)
    assert assigns(:answer)
    assert assigns(:question)
    assert assigns(:notice)
# TODO: We don't appear to be displaying the success/failure notice anywhere in the js.erb
    #assert_select '.welcome-message h2', _('Comment was successfully created.')
    @note.reload
    assert_equal 'Test Note', @note.text, "expected the note's text to be 'Test Note'"
    
    # Invalid save
    put note_path(@note), {note: {id: @note.id}, "#{@question.id}new_note_text": nil}, {'ACCEPT': 'text/javascript'}
    assert_response :success
    assert assigns(:note)
    assert assigns(:plan)
    assert assigns(:answer)
    assert assigns(:question)
    assert assigns(:notice)
# TODO: We don't appear to be displaying the success/failure notice anywhere in the js.erb
    #assert_select '.welcome-message h2', _('Unable to save your changes.')
    assert_equal 'Test Note', @note.text, "expected the note's text to Still be 'Test Note'"
  end
  
  # PATCH /notes/:id/archive (archive_note_path)
  # ----------------------------------------------------------
  test "delete the note" do
    # Should redirect user to the root path if they are not logged in!
    patch archive_note_path(@note), {note: {id: @note.id, archived_by: @user.id}}, {'ACCEPT': 'text/javascript'}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    patch archive_note_path(@note), {note: {id: @note.id, archived_by: @user.id}}, {'ACCEPT': 'text/javascript'}
    assert_response :success
    assert assigns(:note)
    assert assigns(:plan)
    assert assigns(:answer)
    assert assigns(:question)
    assert assigns(:notice)
    
    @note.reload
    assert @note.archived, 'expected the archived flag to be true'
    assert_equal @user.id, @note.archived_by, 'expected the archived_by to be set to @user'
  end
end