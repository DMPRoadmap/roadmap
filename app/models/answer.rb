# == Schema Information
#
# Table name: answers
#
#  id           :integer          not null, primary key
#  lock_version :integer          default(0)
#  text         :text
#  created_at   :datetime
#  updated_at   :datetime
#  plan_id      :integer
#  question_id  :integer
#  user_id      :integer
#
# Indexes
#
#  index_answers_on_plan_id      (plan_id)
#  index_answers_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (question_id => questions.id)
#  fk_rails_...  (user_id => users.id)
#

class Answer < ActiveRecord::Base
  include ValidationMessages

  after_save do |answer|
    if answer.plan_id.present?
      plan = answer.plan
      complete = plan.no_questions_matches_no_answers?
      if plan.complete != complete
        plan.complete = complete
        plan.save!
      else
        plan.touch  # Force updated_at changes if nothing changed since save only saves if changes were made to the record
      end
    end
  end

  ##
  # Associations
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

  ##
  # deep copy the given answer
  #
  # @params [Answer] question_option to be deep copied
  # @return [Answer] the saved, copied answer
  def self.deep_copy(answer)
    answer_copy = answer.dup
    answer.question_options.each do |opt|
      answer_copy.question_options << opt
    end
    answer_copy
  end

  # This method helps to decide if an answer option (:radiobuttons, :checkbox, etc ) in form views should be checked or not
  # Returns true if the given option_id is present in question_options, otherwise returns false
  def has_question_option(option_id)
    self.question_option_ids.include?(option_id)
  end

  # Returns true if the answer is valid and false otherwise. If the answer's question is option_based, it is checked if exist
  # any question_option selected. For non option_based (e.g. textarea or textfield), it is checked the presence of text
  def is_valid?
    if self.question.present?
      if self.question.question_format.option_based?
        return !self.question_options.empty?
      else  # (e.g. textarea or textfield question formats)
        return self.text.present?
      end
    end
    return false
  end

  # Returns answer notes whose archived is blank sorted by updated_at in descending order
  def non_archived_notes
    return notes.select{ |n| n.archived.blank? }.sort!{ |x,y| y.updated_at <=> x.updated_at }
  end

  ##
  # Returns True if answer text is blank, false otherwise
  # specificly we want to remove empty hml tags and check
  #
  # @return [Boolean] is the answer's text blank
  def is_blank?
    if self.text.present?
      return self.text.gsub(/<\/?p>/, '').gsub(/<br\s?\/?>/, '').chomp.blank?
    end
    # no text so blank
    return true
  end

  ##
  # Returns the parsed JSON hash for the current answer object
  # Generates a new hash if none exists for rda_questions
  #
  # @return [Hash] the parsed hash of the answer.
  #                Should have keys 'standards', 'text'
  #                'standards' is a list of <std_id>: <title> pairs
  #                'text' is the text from the comments box
  def answer_hash
    default = {'standards' => {}, 'text' => ''}
    begin
      h = self.text.nil? ? default : JSON.parse(self.text)
    rescue JSON::ParserError => e
      h = default
    end
    return h
  end

  ##
  # Given a hash of standards and a comment value, this updates answer
  # text for rda_questions
  #
  # @param [standards] a hash of standards
  # @param [text]  option comment text
  # nothing returned, but the status of the text field of the answer is changed
  def update_answer_hash(standards={},text="")
    h = {}
    h['standards'] = standards
    h['text'] = text
    self.text = h.to_json
  end
end
