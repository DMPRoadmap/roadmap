# frozen_string_literal: true

DISPLAY_LENGTH = 50

# Helper methods for Conditional Questions
# rubocop:disable Metrics/ModuleLength
module ConditionsHelper
  # return a list of question ids to open/hide
  def remove_list(object)
    id_list = []
    plan_answers = object.answers if object.is_a?(Plan)
    plan_answers = object[:answers] if object.is_a?(Hash)
    return [] if plan_answers.blank?

    plan_answers.each { |answer| id_list += answer_remove_list(answer) }
    id_list
  end

  # returns an array of ids to remove based on the conditions associated with an answer
  # or trigger the email (TODO: combining these is a bit icky!)
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def answer_remove_list(answer, user = nil)
    id_list = []
    return id_list unless answer.question.option_based?

    chosen = answer.question_option_ids.sort

    answer.question.conditions.each do |cond|
      opts = cond.option_list.map(&:to_i).sort
      action = cond.action_type

      # If the chosen (options) include the opts (options list) in the condition,
      # then we apply the action.
      # Currently, the Template edit through the UI only allows an action to be
      # added to a single option at a time,
      # so the opts array is always length 0 or 1.
      # This if checks that all elements in opts are also in chosen.
      if !opts.empty? && !chosen.empty? && opts.intersection(chosen) == opts
        if action == 'remove'
          rems = cond.remove_data.map(&:to_i)
          id_list += rems
        elsif !user.nil?
          UserMailer.question_answered(cond.webhook_data, user, answer,
                                       chosen.join(' and ')).deliver_now
        end
      end
    end
    # uniq because could get same remove id from diff conds
    id_list.uniq
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def send_webhooks(user, answer)
    answer_remove_list(answer, user)
  end

  # rubocop:disable Metrics/AbcSize
  def email_trigger_list(answer)
    email_list = []
    return email_list unless answer.question.option_based?

    answer.question.conditions.each do |cond|
      opts = cond.option_list.map(&:to_i).sort
      action = cond.action_type
      chosen = answer.question_option_ids.sort
      next unless chosen == opts

      email_list << cond.webhook_data['email'] if action == 'add_webhook'
    end
    # uniq because could get same remove id from diff conds
    email_list.uniq.join(',')
  end
  # rubocop:enable Metrics/AbcSize

  # number of answers in a section after answers updated with conditions
  def num_section_answers(plan, section)
    count = 0
    plan_remove_list = remove_list(plan)
    plan.answers.each do |answer|
      next unless answer.question.section_id == section.id &&
                  plan_remove_list.exclude?(answer.question_id) &&
                  section.question_ids.include?(answer.question_id) &&
                  answer.answered?

      count += 1
    end
    count
  end

  # number of questions in a section after update with conditions
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def num_section_questions(plan, section, phase = nil)
    # when section and phase are a hash in exports
    if section.is_a?(Hash) &&
       !phase.nil? &&
       plan.is_a?(Plan)

      phase = plan.template
                  .phases
                  .find { |ph| ph.number == phase[:number] }
      section = phase.sections
                     .find { |s| s.phase_id == phase.id && s.title == section[:title] }
    end
    count = 0
    plan_remove_list = remove_list(plan)
    section.questions.each do |question|
      count += 1 unless plan_remove_list.include?(question.id)
    end
    count
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # returns an array of hashes of section_id, number of section questions, and
  # number of section answers
  def sections_info(plan)
    return [] if plan.nil?

    plan.sections.map do |section|
      section_info(plan, section)
    end
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
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
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

          if collection.key?(key)
            collection[key] += [[question_title(q), q.id]]
          else
            collection[key] = [[question_title(q), q.id]]
          end
        end
      end
    end
    collection
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def question_title(question)
    raw format('Qn. %{question_nbr}: %{title}',
               question_nbr: question.number.to_s,
               title: truncate(strip_tags(question.text), length: DISPLAY_LENGTH,
                                                          separator: ' ', escape: false))
  end

  def section_title(section)
    raw format('Sec. %{section_nbr}: %{title}',
               section_nbr: section.number.to_s,
               title: truncate(strip_tags(section.title), length: DISPLAY_LENGTH,
                                                          separator: ' ', escape: false))
  end

  # used when displaying a question while editing the template
  # converts condition into text
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def condition_to_text(conditions)
    return_string = ''
    conditions.each do |cond|
      opts = cond.option_list.map { |opt| QuestionOption.find(opt).text }
      return_string += '</dd>' unless return_string.empty?
      return_string += "<dd>#{_('Answering')} "
      return_string += opts.join(' and ')
      if cond.action_type == 'add_webhook'
        subject_string = text_formatted(cond.webhook_data['subject'])
        return_string += format(_(' will <b>send an email</b> with subject %{subject_name}'),
                                subject_name: subject_string)
      else
        remove_data = cond.remove_data
        rems = remove_data.map { |rem| "\"#{Question.find(rem).text}\"" }

        return_string += _(' will <b>remove</b> question ') if rems.length == 1
        return_string += _(' will <b>remove</b> questions ') if rems.length > 1
        return_string += rems.join(' and ')
      end
    end
    "#{return_string}</dd>"
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def text_formatted(object)
    text = Question.find(object).text if object.is_a?(Integer)
    text = object if object.is_a?(String)
    return 'type error' if text.blank?

    cleaned_text = text
    text = ActionController::Base.helpers.truncate(cleaned_text, length: DISPLAY_LENGTH,
                                                                 separator: ' ', escape: false)
    "\"#{text}\""
  end

  # convert a set of conditions into multi-select form
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def conditions_to_param_form(conditions)
    param_conditions = {}
    conditions.each do |condition|
      title = "condition #{condition[:number]}"
      condition_hash = { title =>
                        { question_option_id: condition.option_list,
                          action_type: condition.action_type,
                          number: condition.number,
                          remove_question_id: condition.remove_data,
                          webhook_data: condition.webhook_data } }
      if param_conditions.key?(title)
        param_conditions[title].merge!(condition_hash[title]) do |_key, val1, val2|
          if val1.is_a?(Array) && val1.exclude?(val2[0])
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
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # returns an hash of hashes of webhook data given a condition array
  def webhook_hash(conditions)
    web_hash = {}
    param_conditions = conditions_to_param_form(conditions)
    param_conditions.each_value do |params|
      web_hash.merge!(params[:number] => params[:webhook_data])
    end
    web_hash
  end
end
# rubocop:enable Metrics/ModuleLength
