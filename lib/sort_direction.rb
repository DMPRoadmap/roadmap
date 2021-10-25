# frozen_string_literal: true

# Helper class for column sorting in Pagination.
#
# Examples:
#
#   @direction = SortDirection.new(:asc)
#   @direction.to_s # => "ASC"
#   @direction.downcase # => 'asc'
#   @direction.opposite # => 'DESC'
#
#   SortDirection.new(:wrong).to_s # => 'ASC'
#
class SortDirection

  ##
  # When given an unknown or nil direction, default to this value
  DEFAULT_DIRECTION = "ASC"

  ##
  # Possible sort direction values
  DIRECTIONS = %w[ASC DESC].freeze

  ##
  # The direction represented as an uppercase, abbreviated String
  attr_reader :direction

  alias to_s direction

  ##
  # The direction as uppercase
  #
  # Returns String
  delegate :uppercase, to: :direction

  ##
  # The direction as lowercase
  #
  # Returns String
  delegate :downcase, to: :direction

  # Initialize a new SortDirection
  #
  # direction - The direction (asc or desc) we want to sort results by
  def initialize(direction = nil)
    @direction = direction.to_s.upcase.presence_in(DIRECTIONS) || DEFAULT_DIRECTION
  end

  # The opposite direction to this one. Returns asc for desc, and desc for asc.
  #
  # Returns String
  def opposite
    @opposite ||= DIRECTIONS[DIRECTIONS.index(direction) - 1]
  end

end
