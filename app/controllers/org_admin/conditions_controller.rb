# frozen_string_literal: true

class OrgAdmin::ConditionsController < ApplicationController

  # /org_admin/questions/:question_id/conditions/new
  def new
    question = Question.find(params[:question_id])
    condition_no = new_condition_params[:condition_no]
    next_condition_no = condition_no.to_i + 1
    render json: { add_link: render_to_string(partial: "add",
                                              formats: :html,
                                              layout: false,
                                              locals: { question: question,
                                                        condition_no: next_condition_no }),
                   attachment_partial: render_to_string(partial: "form",
                                                        formats: :html,
                                                        layout: false,
                                                        locals: {
                                                          question: question,
                                                          cond: Condition.new(question: question),
                                                          condition_no: condition_no
                                                        }) }
  end

  private

  def new_condition_params
    params.permit(:condition_no)
  end

  def condition_params
    params.require(:question_option_id, :action_type).permit(:remove_question_id, :condition_no)
  end

end
