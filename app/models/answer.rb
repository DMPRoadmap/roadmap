# frozen_string_literal: true

# == Schema Information
#
# Table name: answers
#
#  id           :integer          not null, primary key
#  lock_version :integer          default(0)
#  text         :text
#  created_at   :datetime
#  updated_at   :datetime
#  label_id     :string
#  plan_id      :integer
#  question_id  :integer
#  user_id      :integer
#
# Indexes
#
#  fk_rails_3d5ed4418f           (question_id)
#  fk_rails_584be190c2           (user_id)
#  fk_rails_84a6005a3e           (plan_id)
#  index_answers_on_plan_id      (plan_id)
#  index_answers_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (question_id => questions.id)
#  fk_rails_...  (user_id => users.id)
#

class Answer < ApplicationRecord

  # ================
  # = Associations =
  # ================

  belongs_to :question

  belongs_to :user

  belongs_to :plan

  has_many :notes, dependent: :destroy

  has_and_belongs_to_many :question_options, join_table: "answers_question_options"

  has_many :notes


  # ===============
  # = Validations =
  # ===============

  validates :plan, presence: { message: PRESENCE_MESSAGE }

  validates :user, presence: { message: PRESENCE_MESSAGE }

  validates :question, presence: { message: PRESENCE_MESSAGE },
                      uniqueness: { message: UNIQUENESS_MESSAGE,
                                    scope: :plan_id }

  # =============
  # = Callbacks =
  # =============

  after_save :set_plan_complete

  ##
  # deep copy the given answer
  #
  # answer - question_option to be deep copied
  #
  # Returns Answer
  def self.deep_copy(answer)
    answer_copy = answer.dup
    answer.question_options.each do |opt|
      answer_copy.question_options << opt
    end
    answer_copy
  end

  # This method helps to decide if an answer option (:radiobuttons, :checkbox, etc ) in
  # form views should be checked or not
  #
  # Returns Boolean
  def has_question_option(option_id)
    question_option_ids.include?(option_id)
  end

  # If the answer's question is option_based, it is checked if exist any question_option
  # selected. For non option_based (e.g. textarea or textfield), it is checked the
  # presence of text
  #
  # Returns Boolean
  def answered?
    if question.present?
      if question.question_format.option_based?
        return question_options.any?
      else  # (e.g. textarea or textfield question formats)
        return not(is_blank?)
      end
    end
    false
  end

  # Answer notes whose archived is blank sorted by updated_at in descending order
  #
  # Returns Array
  def non_archived_notes
    notes.select { |n| n.archived.blank? }.sort! { |x, y| x.created_at <=> y.created_at }
  end

  # Returns True if answer text is blank, false otherwise specificly we want to remove
  # empty hml tags and check.
  #
  # Returns Boolean
  def is_blank?
    if text.present?
      return text.gsub(/<\/?p>/, "").gsub(/<br\s?\/?>/, "").chomp.blank?
    end
    # no text so blank
    true
  end

  # The parsed JSON hash for the current answer object. Generates a new hash if none
  # exists for rda_questions.
  #
  # Returns Hash
  def answer_hash
    default = { "standards" => {}, "text" => "" }
    begin
      h = text.nil? ? default : JSON.parse(text)
    rescue JSON::ParserError => e
      h = default
    end
    h
  end

  ##
  # Given a hash of standards and a comment value, this updates answer text for
  # rda_questions
  #
  # standards - A Hash of standards
  # text      - A String with option comment text
  #
  # Returns String
  def update_answer_hash(standards = {}, text = "")
    h = {}
    h["standards"] = standards
    h["text"] = text
    self.text = h.to_json
  end

  def set_plan_complete
    # Remove guard? this is an after-save so unreachable if there is no plan
    return unless plan_id?
    complete = plan.no_questions_matches_no_answers?
    if plan.complete != complete
      plan.update!(complete: complete)
    else
      # Force updated_at changes if nothing changed since save only saves if changes
      # were made to the record
      plan.touch
    end
  end

end
