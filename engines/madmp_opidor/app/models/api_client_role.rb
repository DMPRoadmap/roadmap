# frozen_string_literal: true

# Object that represents an api_client_role
class ApiClientRole < ApplicationRecord
  include FlagShihTzu

  # ================
  # = Associations =
  # ================

  belongs_to :api_client

  belongs_to :plan

  belongs_to :research_output, required: false

  ##
  # Define Bit Field Values
  # Column access
  has_flags 1 => :creator,  # 1
            2 => :edit,     # 2
            3 => :read,     # 4
            column: 'access'

  # ===============
  # = Validations =
  # ===============

  validates :api_client, presence: { message: PRESENCE_MESSAGE }

  validates :plan, presence: { message: PRESENCE_MESSAGE }

  validates :access, presence: { message: PRESENCE_MESSAGE },
                     numericality: { greater_than: 0, only_integer: true,
                                     message: _("can't be less than zero") }
end
