class Section < ActiveRecord::Base
  ##
  # Associations
  belongs_to :phase
  belongs_to :organisation
  has_many :questions, dependent: :destroy
  has_one :template, through: :phase

  # Link the data
  accepts_nested_attributes_for :questions, reject_if: lambda { |a| a[:text].blank? },  allow_destroy: true


  ##
  # Validations
  validates :phase, :title, presence: { message: _("can't be blank") }

  validates :number, presence: { message: _("can't be blank") },
                     uniqueness: { scope: :phase_id }

  before_validation :set_defaults

  ##
  # Scopes

  # The sections for this Phase that have been added by the admin
  #
  # @!scope class
  # @return [ActiveRecord::Relation] Returns the sections that are modifiable
  scope :modifiable, -> { where(modifiable: true) }

  # The sections for this Phase that were part of the original Template
  #
  # @!scope class
  # @return [ActiveRecord::Relation] Returns the sections that aren't modifiable
  scope :not_modifiable, -> { where(modifiable: false) }

  # =================
  # = Class methods =
  # =================

  def self.update_numbers!(*ids, phase:)
    # Ensure only section ids belonging to this Phase are included.
    ids    = ids.map(&:to_i) & phase.section_ids
    return if ids.empty?
    # Build an Array with each ID and its relative position in the Array
    values = ids.each_with_index.map { |id, i| "(#{id}, #{i + 1})" }.join(", ")
    # Run a single UPDATE query for all records.
    query  = <<~SQL
      UPDATE #{table_name} \
        SET number = svals.number \
        FROM (VALUES #{sanitize_sql(values)}) AS svals(id, number) \
        WHERE svals.id = #{table_name}.id;
      SQL
    connection.execute(query, "Section Update number")
  end

  ##
  # return the title of the section
  #
  # @return [String] the title of the section
  def to_s
    "#{title}"
  end

  # Returns the number of answered questions for a given plan
  def num_answered_questions(plan)
    return 0 if plan.nil?
    questions_hash = questions.reduce({}) { |m, q| m[q.id] = q; m }
    plan.answers.includes({ question: :question_format }, :question_options).reduce(0) do |m, a|
      if questions_hash[a.question_id].present? && a.is_valid?
        m+= 1
      end
      m
    end
  end

  def deep_copy(**options)
    copy = self.dup
    copy.modifiable = options.fetch(:modifiable, self.modifiable)
    copy.phase_id = options.fetch(:phase_id, nil)
    copy.save!(validate: false)  if options.fetch(:save, false)
    options[:section_id] = copy.id
    self.questions.map{ |question| copy.questions << question.deep_copy(options) }
    return copy
  end

  private
    def set_defaults
      self.modifiable = true if modifiable.nil?
    end
end
