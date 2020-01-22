# frozen_string_literal: true

class AnswersController < ApplicationController

  respond_to :html
  include ConditionsHelper

  # POST /answers/create_or_update
  def create_or_update
    p_params = permitted_params()

    # First it is checked plan exists and question exist for that plan
    begin
      p = Plan.find(p_params[:plan_id])
      if !p.question_exists?(p_params[:question_id])
        # rubocop:disable Metrics/LineLength
        render(status: :not_found, json: {
          msg: _("There is no question with id %{question_id} associated to plan id %{plan_id} for which to create or update an answer") % {
            question_id: p_params[:question_id],
            plan_id: p_params[:plan_id]
          }
        })
        # rubocop:enable Metrics/LineLength
        return
      end
      remove_list_before = remove_list(p)
    rescue ActiveRecord::RecordNotFound
      # rubocop:disable Metrics/LineLength
      render(status: :not_found, json: {
        msg: _("There is no plan with id %{id} for which to create or update an answer") % {
          id: p_params[:plan_id]
        }
      })
      # rubocop:enable Metrics/LineLength
      return
    end
    q = Question.find(p_params[:question_id])

    # rubocop:disable Metrics/BlockLength
    Answer.transaction do
      begin
        @answer = Answer.find_by!(
          plan_id: p_params[:plan_id],
          question_id: p_params[:question_id]
        )
        authorize @answer
        @answer.update(p_params.merge(user_id: current_user.id))
        if p_params[:question_option_ids].present?
          # Saves the record with the updated_at set to the current time.
          # Needed if only answer.question_options is updated
          @answer.touch()
        end
        if q.question_format.rda_metadata?
          @answer.update_answer_hash(
            JSON.parse(params[:standards]), p_params[:text]
          )
          @answer.save!
        end
      rescue ActiveRecord::RecordNotFound
        @answer = Answer.new(p_params.merge(user_id: current_user.id))
        @answer.lock_version = 1
        authorize @answer
        if q.question_format.rda_metadata?
          @answer.update_answer_hash(
            JSON.parse(params[:standards]), p_params[:text]
          )
        end
        @answer.save!
      rescue ActiveRecord::StaleObjectError
        @stale_answer = @answer
        @answer = Answer.find_by(
          plan_id: p_params[:plan_id],
          question_id: p_params[:question_id]
        )
      end
    end
    # rubocop:enable Metrics/BlockLength

    if @answer.present?
      @plan = Plan.includes(
        sections: {
          questions: [
            :answers,
            :question_format
          ]
        }
      ).find(p_params[:plan_id])
      @question = @answer.question
      @section = @plan.sections.find_by(id: @question.section_id)
      template = @section.phase.template

      remove_list_after = remove_list(@plan)
      # in case of any condition chains
      remove_list_after = remove_list(@plan, remove_list_after)
      # get section info for the questions to be hidden and shown for this plan
      qn_data = sections_info_from_questions(list_compare(remove_list_before, remove_list_after), @plan)
      this_section_info = sections_info_from_questions(
        {
          to_show: [@answer.question_id],
          to_hide: []
        }, 
        @plan
      )
      send_webhooks(current_user, @answer)
      # rubocop:disable Metrics/LineLength
      render json: {
        "qn_data": qn_data,
        "this_section_info": this_section_info,
        "question" => {
          "id" => @question.id,
          "answer_lock_version" => @answer.lock_version,
          "locking" => @stale_answer ?
            render_to_string(partial: "answers/locking", locals: {
              question: @question,
              answer: @stale_answer,
              user: @answer.user
            }, formats: [:html]) :
            nil,
          "form" => render_to_string(partial: "answers/new_edit", locals: {
            template: template,
            question: @question,
            answer: @answer,
            readonly: false,
            locking: false,
            base_template_org: template.base_org
          }, formats: [:html]),
          "answer_status" => render_to_string(partial: "answers/status", locals: {
            answer: @answer
          }, formats: [:html])
        },
        "plan" => {
          "id" => @plan.id,
          "progress" => render_to_string(partial: "plans/progress", locals: {
            plan: @plan,
            current_phase: @section.phase
          }, formats: [:html])
        }
      }.to_json
      # rubocop:enable Metrics/LineLength
    end
  end

  # hash of an array of question ids to show and of ids to hide
  def list_compare(before, after)
    id_hash = {}
    # hide what questions (by id) have just been added to to_remove
    id_hash.merge!(to_hide: comparison(after, before))
    # show what questions (by id) just no longer in to_remove
    id_hash.merge!(to_show: comparison(before, after))
    id_hash
  end

 # in set notation returns array1 \ array2
  def comparison(array1, array2)
    show_or_hide = []
    array1.each do |id|
      unless array2.include?(id)
        show_or_hide.push(id)
      end
    end
    show_or_hide.uniq
  end

  # get the section info relating to the questions to add and remove.
  # section info:
  #   section id,
  #   number of questions per section,
  #   number of answers per section
  # all for a given question id
  def sections_info_from_questions(qn_hash, plan)
    sec_hash = {}
    sec_hash.merge!(to_hide: merge_info(qn_hash[:to_hide], plan))
    sec_hash.merge!(to_show: merge_info(qn_hash[:to_show], plan))
    sec_hash
  end

  # goes from array of question ids to array of hashes of section info
  def merge_info(show_or_hide_array, plan)
    show_or_hide_info = []
    show_or_hide_array.each do |id|
      question = Question.find(id)
      info = section_info(plan, question.section)
      question_hash = {}
                        .merge!(qn_id: id)
                        .merge!(sec_id: info[:id])
                        .merge!(no_qns: info[:no_qns])
                        .merge!(no_ans: info[:no_ans])
      show_or_hide_info.push(question_hash)
    end
    show_or_hide_info.uniq
  end

  private
  def permitted_params
    permitted = params.require(:answer).permit(:id, :text, :plan_id, :user_id,
                                               :question_id, :lock_version,
                                               question_option_ids: [])
    # If question_option_ids has been filtered out because it was a
    # scalar value (e.g. radiobutton answer)
    if !params[:answer][:question_option_ids].nil? &&
       !permitted[:question_option_ids].present?
      permitted[:question_option_ids] = [params[:answer][:question_option_ids]]
    end
    if !permitted[:id].present?
      permitted.delete(:id)
    end
    # If no question options has been chosen.
    if params[:answer][:question_option_ids].nil?
        permitted[:question_option_ids] = []
    end
    permitted
  end

end
