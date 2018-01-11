class QuestionFormat < ActiveRecord::Base

  ##
  # Associations
  has_many :questions

  enum formattype: [ :textarea, :textfield, :radiobuttons, :checkbox, :dropdown, :multiselectbox, :date, :rda_metadata ]
  attr_accessible :formattype

  validates :title, presence: {message: _("can't be blank")}, uniqueness: {message: _("must be unique")}

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :title, :description, :option_based, :questions, :as => [:default, :admin]

  # Retrieves the id for a given formattype passed
  scope :id_for, -> (formattype) { where(formattype: formattype).pluck(:id).first }

  ##
  # Define Bit Field Values so we can test a format without doing string comps
  # Column type

  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?


  ##
  # gives the title of the question_format
  #
  # @return [String] title of the question_format
  def to_s
    "#{title}"
  end

end
