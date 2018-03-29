class NotificationType < ActiveRecord::Base
  has_many :notifications

  # Return the NotificationType name capitalized
  # @return [String] the capitalized name
  def capitalized_name
    name.capitalize
  end
end
