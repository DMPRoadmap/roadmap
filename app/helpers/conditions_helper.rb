module ConditionsHelper

  # refactor with polymorphism - doesn't seem to make it any cleaner though...
  def remove_list(object, old_list = []) # returns list of questions to remove given a Plan, Answer, or Plan Hash
    id_list = []
    if object.is_a?(Answer)
      id_list += answer_conditions(object)
      return id_list.uniq
    elsif object.is_a?(Plan)
      planAnswers = object.answers
    elsif object.is_a?(Hash)
      planAnswers = object[:answers]
    else
      return []
    end
    planAnswers.each do |answer|
      answer_conditions(answer).each do |remove_ids|
        if !old_list.include?(answer.question.id)
          id_list.push(remove_ids)
        end
      end
    end
    id_list.uniq
  end

  # returns an array of ids to remove based on the conditions associated with an answer
  def answer_conditions(answer, user = nil)
    id_list = []
    if answer.question.option_based?
      p_conditions = conditions_to_param_form(answer.question.conditions)
      p_conditions.each do |number, p_condition|
        a1 = answer.question_option_ids
        a2 = p_condition[:question_option_id]
        if a1 & a2 == a2 && a1.length == a2.length # test if right question option selection a.k.a. arrays are equal
          if p_condition[:action_type] == 'remove' # both expressions should have the same boolean value
            id_list += p_condition[:remove_question_id]
          elsif user != nil
            UserMailer.question_answered(JSON.parse(p_condition[:webhook_data]), user, answer, options_string(a2)).deliver_now()
          end
        end
      end
    end
    id_list
  end

  # this will be omitted (and replaced with answer_conditions(answer, user)) but used to show specific webhook call
  def send_webhooks(user, answer)
    answer_conditions(answer, user)
  end

  # number of answers in a section after answers updated with conditions
  def num_section_answers(plan, section) 
    count = 0
    plan.answers.each do |answer|
      if answer.question.section.id == section.id &&
       !remove_list(plan).include?(answer.question.id) && section.answered_questions(plan).include?(answer) && answer.answered?
        count += 1
      end
    end
    count
  end

  # number of questions in a section after update with conditions
  def num_section_questions(plan, section, phase = nil)
    if section.kind_of?(Hash) && phase != nil && plan.kind_of?(Plan) # when section and phase are a hash in exports
      phase_id = plan.phases.where(number: phase[:number]).first.id
      section = plan.sections.where(phase_id: phase_id, title: section[:title]).first
    end
    count = 0
    plan.questions.each do |question|
      if question.section.id == section.id &&
        !remove_list(plan).include?(question.id)
        count += 1
      end
    end
    count
  end

  # returns an array of hashes of section_id, number of section questions, and number of section answers
  def sections_info(plan) 
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


	# returns a collection of questions to remove (hide). Choose from these which are to be removed by a given condition
  def remove_question_collection(question)
    collection = []
    question.section.phase.template.phases.each_with_index do |ph, idx|
      if not_previous_phase?(question, ph)
        sections = ph.sections.map { |s|
                  [section_title(s), s.questions.map { |q| 
                  [question_title(q), q.id] if not_previous_question?(question, q) }.compact 
                  ] if not_previous_section?(question, s) }.compact
        if idx == 0
          collection = sections
        else
          collection += sections
        end
      end
    end
    collection
  end

  def question_title(question)
    raw "Qn. " + question.number.to_s + ": " + truncate(strip_tags(question.text), length: 50, separator: " ", escape: false)
  end

  def section_title(section)
    raw "Sec. " + section.number.to_s + ": " + truncate(strip_tags(section.title), length: 50, separator: " ", escape: false)
  end

  def not_previous_phase?(current_question, dropdown_phase)
    current_question.phase.number <= dropdown_phase.number
  end

  def not_previous_section?(current_question, dropdown_section)
    current_question.section.number < dropdown_section.number || # later section
    current_question.phase.number < dropdown_section.phase.number || # later phase
    (current_question.section.number == dropdown_section.number && current_question.number != dropdown_section.questions.size) # not last question of this section
  end

  def not_previous_question?(current_question, dropdown_question)
    current_question.number < dropdown_question.number || # later question
    current_question.section.number < dropdown_question.section.number || # later section
    current_question.phase.number < dropdown_question.phase.number # later phase
  end

  def group_show_conditions(conditions) # given a conditions array, group conditions by number as a hash
    conditions_grouping = {}
    conditions.each do |condition|
      conditions_grouping.merge!(condition.number => [condition]){|op, cond1, cond2| 
        if cond1.kind_of?(Array) && cond2.kind_of?(Array)
          cond1 + cond2
        end
      }
    end 
    return conditions_grouping
  end

  def conditions_ordered(conditions) # ensures conditions of type 'remove' come first. conditions of type Condition
    grouped_conditions = group_show_conditions(conditions)
    grouped_conditions.each do |option, conditions| 
      conditions.sort_by{|condition| condition.action_type.to_s.length}
    end
    grouped_conditions
  end

  def list_questions(conditions) 
    return_string = _('Answering ')
    return_string += options_string(conditions)
    if conditions.size == 1 && conditions[0].action_type == 'add_webhook'
      subject_string = text_formatted(JSON.parse(conditions[0].webhook_data)['subject'])
      return_string += _(' will ') + make_tags('b', _('send an email')) + _(' with subject ') + subject_string
    else 
      remove_array = conditions.select{|c| c.action_type == 'remove'}.map(&:remove_question_id).uniq
      no_removes = remove_array.uniq.size
      remove_array.each_with_index do |id, idx|
        if idx < no_removes
          if idx == 0
            return_string += _(' will ') + make_tags('b', _('remove '))
          elsif idx < no_removes - 1
            return_string += _(', ')
          elsif idx == no_removes - 1
            return_string += _(', and ')
          end
          return_string += text_formatted(id)
        else
          if idx > 0 
            return_string += _(', and ')
          end
          return_string += _(' will ') + make_tags('b', _('send an email'))
        end
      end
    end
    return_string += "."
  end

  def make_tags(tag, string)
    "<#{tag}> #{string} </#{tag}>"
  end

  def options_string(object_array)
    options = []
    if object_array[0].kind_of?(Condition)
      options = get_options(object_array)
    elsif object_array[0].kind_of?(Integer)
      options = QuestionOption.find(object_array).map(&:text)
    end  
    return_string = ""
    options.each_with_index do |option, idx|
      return_string += text_formatted(option)
      if idx != options.length - 1 && options.length != 1
        return_string += _(', ')
      end
      if idx == options.length - 2
        return_string += _('and ')
      end
    end
    return_string
  end

  def get_options(conditions)
    options_list = []
    conditions.each do |condition|
      options_list.push(condition.question_option.text)
    end
    options_list.uniq
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

  def conditions_to_param_form(conditions)
    param_conditions = {}
    conditions.each do |condition|
      title = "condition" + condition[:number].to_s
      condition_hash = {title => 
                        {question_option_id: [condition.question_option_id], 
                        action_type: condition.action_type, 
                        number: condition.number,
                        remove_question_id: [condition.remove_question_id],
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







