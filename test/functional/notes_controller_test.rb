require 'test_helper'

class NotesControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.last

    scaffold_plan
    # Assign the user to the plan as a commenter/reader
    @plan.assign_reader(@user.id)
    @plan.save!

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
    params = {user_id: @user.id, answer_id: @answer.id, plan_id: @plan.id, question_id: @question.id, text: 'Test Note'}

    # Should redirect user to the root path if they are not logged in!
    post notes_path, {note: params}
    assert_unauthorized_redirect_to_root_path

    sign_in @user

    post notes_path, {note: params}, {'ACCEPT': 'application/json'}
    assert_response :success
    assert assigns(:note)
    assert assigns(:plan)
    assert assigns(:answer)
    assert assigns(:question)
    assert assigns(:notice)
    #assert_select '.welcome-message h2', _('Comment was successfully created.')
    assert_equal 'Test Note', Note.last.text, 'Expected the note to have been created'

    # No Answer
    post notes_path, {note: {user_id: @user.id, plan_id: @plan.id, question_id: @question.id}}, {'ACCEPT': 'application/json'}
    assert_response :bad_request
    # TODO: expected the new note to have been added :/
    #assert_equal 'Test Note no Answer', Note.last.text, 'Expected the note to have been created even if there was no answer'

    # Invalid object
    post notes_path, {note: {user_id: @user.id, answer_id: @answer.id, plan_id: @plan.id,
                                                  question_id: @question.id}}, {'ACCEPT': 'application/json'}
    assert_response :bad_request
    assert assigns(:note)
    assert assigns(:plan)
    assert assigns(:answer)
    assert assigns(:question)
    assert assigns(:notice)
  end

  # PUT /notes/:id (note_path)
  # ----------------------------------------------------------
  test "update the note" do
    # Should redirect user to the root path if they are not logged in!
    put note_path(@note), { note: { text: 'Test Note' }, id: @note.id }, {'ACCEPT': 'application/json'}
    assert_unauthorized_redirect_to_root_path

    sign_in @user

    # Valid save
    put note_path(@note), { note: {text: 'Test Note' }, id: @note.id }, {'ACCEPT': 'application/json'}
    assert_response :success
    assert assigns(:note)
    assert assigns(:plan)
    assert assigns(:answer)
    assert assigns(:question)
    assert assigns(:notice)
    @note.reload
    assert_equal 'Test Note', @note.text, "expected the note's text to be 'Test Note'"

    # Invalid save
    put note_path(@note), { note: { text: nil }, id: @note.id }, {'ACCEPT': 'application/json'}
    assert_response :bad_request
    assert assigns(:notice)
    assert_equal 'Test Note', @note.text, "expected the note's text to Still be 'Test Note'"
  end

  # PATCH /notes/:id/archive (archive_note_path)
  # ----------------------------------------------------------
  test "delete the note" do
    # Should redirect user to the root path if they are not logged in!
    patch archive_note_path(@note), { note: { archived_by: @user.id }, id: @note.id }, {'ACCEPT': 'application/json'}
    assert_unauthorized_redirect_to_root_path

    sign_in @user

    patch archive_note_path(@note), { note: { archived_by: @user.id }, id: @note.id }, {'ACCEPT': 'application/json'}
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
