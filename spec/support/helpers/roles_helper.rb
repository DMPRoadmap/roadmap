# frozen_string_literal: true

# rubocop:disable Style/OptionalBooleanParameter
module RolesHelper
  def build_plan(administrator = false, editor = false, commenter = false)
    org = create(:org)
    plan = create(:plan, answers: 2, guidance_groups: 2, org: org)
    creator = create(:user, org: org)
    create(:role, :creator, :active, plan: plan, user: creator)

    create(:role, :administrator, :active, plan: plan, user: create(:user, org: org)) if administrator
    create(:role, :editor, :active, plan: plan, user: create(:user, org: org)) if editor
    create(:role, :commenter, :active, plan: plan, user: create(:user, org: org)) if commenter
    plan
  end
end
# rubocop:enable Style/OptionalBooleanParameter
