# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  access     :integer          default(0), not null
#  active     :boolean          default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#  plan_id    :integer
#  user_id    :integer
#
# Indexes
#
#  index_roles_on_plan_id  (plan_id)
#  index_roles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (user_id => users.id)
#

# Object that represents a User's relationship to a Plan
class Role < ApplicationRecord
  include FlagShihTzu

  attribute :active, :boolean, default: true

  # ================
  # = Associations =
  # ================

  belongs_to :user

  belongs_to :plan

  ##
  # Define Bit Field Values
  # Column access
  has_flags 1 => :creator,            # 1
            2 => :administrator,      # 2
            3 => :editor,             # 4
            4 => :commenter,          # 8
            5 => :reviewer,           # 16
            column: 'access',
            check_for_column: !Rails.env.test?

  # ===============
  # = Validations =
  # ===============

  validates :user, presence: { message: PRESENCE_MESSAGE }

  validates :plan, presence: { message: PRESENCE_MESSAGE }

  validates :active, inclusion: { in: BOOLEAN_VALUES,
                                  message: INCLUSION_MESSAGE }

  validates :access, presence: { message: PRESENCE_MESSAGE },
                     numericality: { greater_than: 0, only_integer: true,
                                     message: _("can't be less than zero") }

  ##
  # Roles with given FlagShihTzu access flags
  #
  # flags - One or more symbols that represent access flags
  #
  # Return ActiveRecord::Relation
  scope :with_access_flags, lambda { |*flags|
    bad_flag = flags.detect { |flag| !flag.in?(flag_mapping['access'].keys) }
    raise ArgumentError, "Unkown access flag '#{bad_flag}'" if bad_flag

    access_values = flags.map { |flag| sql_in_for_flag(flag.to_sym, 'access') }
                         .flatten
                         .uniq
    where(access: access_values)
  }

  # =================
  # = Class Methods =
  # =================

  ##
  # Get the integer values that correspond to a given access flag
  # Convert into a condition, take the numerical half, remove formatting
  # split on commas, and then convert each to an integer
  #
  # access - The symbol corresponding to the user's access, i.e. :editor
  #
  # Returns [Integer]
  def self.bit_values(access)
    Role.send(:chained_flags_values, 'access', access)
  end

  # ===========================
  # = Public instance methods =
  # ===========================

  # Set the roles.active flag to false and deactivates the plan
  # if there are no other authors
  def deactivate!
    self.active = false
    if save!
      # Set the org_id on the Plan before calling deactivate. The org_id should
      # not be blank. This catches the scenario where the `upgrade:v2_2_0_part1`
      # upgrade task has not been run or it missed a record for some reason
      plan.org_id = user.org_id unless plan.org_id.present?
      plan.deactivate! if plan.authors.empty?
      true
    else
      false
    end
  end
end

# -----------------------------------------------------
# Bitwise key
# -----------------------------------------------------
# 01 - creator
# 02 - administrator
# 03 - creator + administrator
# 04 - editor
# 05 - creator + editor
# 06 - administraor + editor
# 07 - creator + editor + administrator
# 08 - commenter
# 09 - creator + commenter
# 10 - administrator + commenter
# 11 - creator + administrator + commenter
# 12 - editor + commenter
# 13 - creator + editor + commenter
# 14 - administrator + editor + commenter
# 15 - creator + administrator + editor + commenter
# 16 - reviewer
# 17 - creator + reviewer
# 18 - administrator + reviewer
# 19 - creator + administrator + reviewer
# 20 - editor + reviewer
# 21 - creator + editor + reviewer
# 22 - administraor + editor + reviewer
# 23 - creator + editor + administrator + reviewer
# 24 - commenter + reviewer
# 25 - creator + commenter + reviewer
# 26 - administrator + commenter + reviewer
# 27 - creator + administrator + commenter + reviewer
# 28 - editor + commenter + reviewer
# 29 - creator + editor + commenter + reviewer
# 30 - administrator + editor + commenter + reviewer
# 31 - creator + administrator + editor + commenter + reviewer
