module Dmpopidor
  module Controllers
    module Notes
      # Delivered mail contains the name of the collaborator leaving the note
      def create
        @note = Note.new
        @note.user_id = note_params[:user_id]
        # ensure user has access to plan BEFORE creating/finding answer
        unless Plan.find_by(id: note_params[:plan_id]).readable_by?(@note.user_id)
          raise Pundit::NotAuthorizedError
        end
        Answer.transaction do
          @answer = Answer.find_by(
            plan_id: note_params[:plan_id],
            question_id: note_params[:question_id]
          )
          if @answer.blank?
            @answer             = Answer.new
            @answer.plan_id     = note_params[:plan_id]
            @answer.question_id = note_params[:question_id]
            @answer.user_id     = @note.user_id
            @answer.save!
          end
        end
        
        @note.answer = @answer
        @note.text = note_params[:text]
        
        authorize @note
        
        @plan = @answer.plan
        
        @question = Question.find(note_params[:question_id])
        
        if @note.save
          @status = true
          answer = @note.answer
          plan = answer.plan
          collaborators = plan.users.reject { |u| u == current_user || !u.active }
          collaborators.uniq.each do |collaborator|
            deliver_if(recipients: collaborator, key: 'users.new_comment') do |r|
              UserMailer.new_comment(current_user, plan, collaborator).deliver_later
            end
          end
          @notice = success_message(@note, _("created"))
          render(json: {
            "notes" => {
              "id" => note_params[:question_id],
                "html" => render_to_string(partial: "layout", locals: {
                  plan: @plan,
                  question: @question,
                  answer: @answer
                }, formats: [:html])
              },
              "title" => {
                "id" => note_params[:question_id],
                "html" => render_to_string(partial: "title", locals: {
                  answer: @answer
                }, formats: [:html])
              }
            }.to_json, status: :created)
        else
          @status = false
          @notice = failure_message(@note, _("create"))
          render json: {
            "msg" => @notice
          }.to_json, status: :bad_request
        end
      end
    end
  end
end