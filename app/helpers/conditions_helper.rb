# frozen_string_literal: true

module ConditionsHelper


  # return a list of question ids to open/hide
  def remove_list(object)
    id_list = []
    if object.is_a?(Plan)
      plan_answers = object.answers
    elsif object.is_a?(Hash)
      plan_answers = object[:answers]
    else
      # TODO: change this to an exception as it shouldn't happen
      return []
    end
    plan_answers.each do |answer|
      id_list += answer_remove_list(answer)
    end
    id_list
  end

  # returns an array of ids to remove based on the conditions associated with an answer
  # or trigger the email (TODO: combining these is a bit icky!)
  def answer_remove_list(answer, user = nil)
    id_list = []
    return id_list unless answer.question.option_based?
    answer.question.conditions.each do |cond|
      opts = cond.option_list.map{ |s| s.to_i }.sort
      action = cond.action_type
      chosen = answer.question_option_ids.sort
      if chosen == opts
        if action == "remove"
          rems = cond.remove_data.map{ |s| s.to_i }
          id_list += rems
        elsif !user.nil?
          UserMailer.question_answered(JSON.parse(cond.webhook_data), user, answer, chosen.join(" and ")).deliver_now
        end
      end
    end
    # uniq because could get same remove id from diff conds
    id_list.uniq
  end

  def send_webhooks(user, answer)
    answer_remove_list(answer, user)
  end
  
  def email_trigger_list(answer)
    email_list = []
    return email_list unless answer.question.option_based?
    answer.question.conditions.each do |cond|
      opts = cond.option_list.map{ |s| s.to_i }.sort
      action = cond.action_type
      chosen = answer.question_option_ids.sort
      if chosen == opts
        if action == "add_webhook"
          email_list << JSON.parse(cond.webhook_data)["email"]
        end
      end
    end
    # uniq because could get same remove id from diff conds
    email_list.uniq.join(',')
  end

  # number of answers in a section after answers updated with conditions
  def num_section_answers(plan, section)
    count = 0
    plan_remove_list = remove_list(plan)
    plan.answers.each do |answer|
      if answer.question.section.id == section.id &&
         !plan_remove_list.include?(answer.question.id) &&
         section.answered_questions(plan).include?(answer) &&
         answer.answered?
        count += 1
      end
    end
    count
  end

  # number of questions in a section after update with conditions
  def num_section_questions(plan, section, phase = nil)
    # when section and phase are a hash in exports
    if section.is_a?(Hash) &&
       !phase.nil? &&
       plan.is_a?(Plan)
      phase_id = plan.phases.where(number: phase[:number]).first.id
      section = plan.sections.where(phase_id: phase_id, title: section[:title]).first
    end
    count = 0
    plan_remove_list = remove_list(plan)
    plan.questions.each do |question|
      if question.section.id == section.id &&
         !plan_remove_list.include?(question.id)
        count += 1
      end
    end
    count
  end

  # returns an array of hashes of section_id, number of section questions, and number of section answers
  def sections_info(plan)
    return [] if plan.nil?

    info = []
    plan.sections.each do |section|
      info.push(section_info(plan, section))
    end
    info
  end

  def section_info(plan, section)
    section_hash = {}
    section_hash[:id] = section.id
    section_hash[:no_qns] = num_section_questions(plan, section)
    section_hash[:no_ans] = num_section_answers(plan, section)
    section_hash
  end

  # collection of questions that could be removed by this question
  # basically all question forward if this one
  # in a form which is suitable for the bootstrap-select menus
  # of the form
  # { secion_title => [
  #    [question_title, question_id],
  #    [question_title, question_id],
  #    ...
  #  ]
  # }
  def later_question_list(question)
    collection = {}
    question.section.phase.template.phases.each do |phase|
      next if phase.number < question.phase.number

      phase.sections.each do |section|
        next if phase.number == question.phase.number &&
                section.number < question.section.number

        # original funder template sections will not be modifiable
        next unless section.modifiable

        section.questions.each do |q|
          next if phase.number == question.phase.number &&
            section.number == question.section.number &&
            q.number <= question.number

          key = section_title(section)

          if collection.has_key?(key)
            collection[key] += [[question_title(q), q.id]]
          else
            collection[key] = [[question_title(q), q.id]]
          end
        end
      end
    end
    collection
  end


  def question_title(question)
    raw "Qn. " + question.number.to_s + ": " +
        truncate(strip_tags(question.text),
                 length: 50,
                 separator: " ",
                 escape: false)
  end

  def section_title(section)
    raw "Sec. " + section.number.to_s + ": " +
        truncate(strip_tags(section.title),
                 length: 50,
                 separator: " ",
                 escape: false)
  end


  # used when displaying a question while editing the template
  # converts condition into text
  def condition_to_text(conditions)
    return_string = ""
    conditions.each do |cond|
      opts = cond.option_list.map{ |opt| QuestionOption.find(opt).text }
      return_string += "</dd>" if return_string.length > 0
      return_string += "<dd>" + _("Answering") + " "
      return_string += opts.join(" and ")
      if cond.action_type == "add_webhook"
        subject_string = text_formatted(JSON.parse(cond.webhook_data)["subject"])
        return_string += _(" will <b>send an email</b> with subject ") + subject_string
      else
        remove_data = cond.remove_data
        rems = remove_data.map{ |rem| '"' + Question.find(rem).text + '"' }

        if rems.length == 1
          return_string += _(" will <b>remove</b> question ")
          return_string += rems.join(" and ")
        else
          return_string += _(" will <b>remove</b> questions ")
          return_string += rems.join(" and ")
        end
      end
    end
    return_string + "</dd>"
  end

  def text_formatted(object)
    length = 50
    if object.kind_of?(Integer) # when remove question id
      text = Question.find(object).text
    elsif object.kind_of?(String) # when email subject
      text = object
      length = 30
    else
      pp 'type error'
    end
    cleaned_text = text
    text = ActionController::Base.helpers.truncate(cleaned_text, length: length, separator: " ", escape: false)
    text = _('"') + text + _('"')
  end

  # convert a set of conditions into multi-select form
  def conditions_to_param_form(conditions)
    param_conditions = {}
    conditions.each do |condition|
      title = "condition" + condition[:number].to_s
      condition_hash = {title =>
                        {question_option_id: condition.option_list,
                        action_type: condition.action_type,
                        number: condition.number,
                        remove_question_id: condition.remove_data,
                        webhook_data: condition.webhook_data}
                       }
      if param_conditions.has_key?(title)
        param_conditions[title].merge!(condition_hash[title]) do |key, val1, val2|
          if val1.kind_of?(Array) && !val1.include?(val2[0])
            val1 + val2
          else
            val1
          end
        end
      else
        param_conditions.merge!(condition_hash)
      end
    end
    param_conditions
  end
 
  # returns an hash of hashes of webhook data given a condition array
  def webhook_hash(conditions)
    web_hash = {}
    param_conditions = conditions_to_param_form(conditions)
    param_conditions.each do |title, params|
      web_hash.merge!(params[:number] => params[:webhook_data])
    end
    web_hash
  end
end
