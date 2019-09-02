module ConditionsHelper

  def remove_list(object) # returns list of questions to remove given a Plan, Answer, or Plan Hash
    id_list = []
    if object.is_a?(Answer)
      answer = object
      id_list.push(answer_conditions(answer))
    elsif object.is_a?(Plan)
      planAnswers = object.answers
    elsif object.is_a?(Hash)
      planAnswers = object[:answers]
    else
      return []
    end
    planAnswers.each do |answer|
      answer_conditions(answer).each do |remove_id|
        id_list.push(remove_id)
      end
    end
    id_list.uniq
  end

  def answer_conditions(answer)
    id_list = []
    if answer.question.option_based?
      answer.question.conditions.each do |condition|
        if condition.action_type == 'remove' && answer.question_option_ids.include?(condition.question_option_id)
          id_list.push(condition.remove_question_id)
        end
      end
    end
    id_list
  end

  # number of answers in a section after answers updated with conditions
  def num_section_answers(plan, section) 
    count = 0
    plan.answers.each do |answer|
      if answer.question.section.id == section.id &&
       !remove_list(plan).include?(answer.question.id)
        count += 1
      end
    end
    count
  end

  def num_section_questions(plan, section)
    count = 0
    plan.questions.each do |question|
      if question.section.id == section.id &&
        !remove_list(plan).include?(question.id)
        count += 1
      end
    end
    count
  end

  def sections_info(plan) # returns an array of hashes of section_id, number of section questions, and number of section answers
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


	# returns a collection of questions to remove (hide) based on what questions have been answered
  # already in a particular plan
  def remove_question_collection(question)
    collection = nil
    question.section.phase.template.phases.each_with_index do |ph, idx|
      if not_previous_phase?(question, ph)
        sections = ph.sections.map { |s|
                  [section_title(s), s.questions.map { |q| 
                  [question_title(q), q.id] if not_previous_question?(question, q) }.compact 
                  ] if not_previous_section?(question, s) }.compact
        if idx == 0
          collection = sections
        else
          collection.push(sections[0])
        end
      end
    end
    collection
  end

  def question_title(question)
    "Qn. " + question.number.to_s + ": " + truncate(strip_tags(question.text), length: 30, separator: " ")
  end

  def section_title(section)
    "Sec. " + section.number.to_s + ": " + truncate(strip_tags(section.title), length: 30, separator: " ")
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

  def group_show_conditions(conditions) # given a conditions array group conditions from the same question option
    conditions_grouping = {}
    conditions.each do |condition|
      conditions_grouping.merge!(condition.question_option => [condition]){|op, cond1, cond2| 
        if cond1.kind_of?(Array) && cond2.kind_of?(Array)
          cond1 + cond2
        else
          pp 'error: cond2 should be type Array'
          ['type error']
        end
      }
    end 
    return conditions_grouping
  end

  def conditions_ordered(conditions) # ensures condtions of type 'remove' come first
    grouped_conditions = group_show_conditions(conditions)
    grouped_conditions.each do |option, conditions| 
      conditions.sort_by{|condition| condition.action_type.to_s.length}
    end
    grouped_conditions
  end

  def list_questions(conditions) 
    return_string = _('Answering ') + conditions[0].question_option.text
    no_removes = conditions.count{|condition| condition.action_type == 'remove'}
    conditions.each_with_index do |condition, idx|
      if idx < no_removes
        if idx == 0
          return_string += _(' will remove ')
        elsif idx < no_removes - 1
          return_string += ", "
        elsif idx == no_removes - 1
          return_string += _(', and ')
        end
        return_string += question_text_formatted(condition.remove_question_id)
      else
        if idx > 0 
          return_string += _(', and ')
        end
        return_string += _(' will add a webhook')
      end
    end
    return_string += "."
    return_string
  end

  def question_text_formatted(id)
    remove_question = Question.find(id)
    question_text = sanitize strip_tags remove_question.text
    truncate(question_text, length: 50, separator: " ")
  end
end












