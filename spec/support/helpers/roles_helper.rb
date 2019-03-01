module RolesHelper

  def build_plan(administrator = false, editor = false, commenter = false, reviewer = false)
    org = create(:org)
    creator = create(:user, org: org)
    plan = create(:plan, answers: 2, guidance_groups: 2)
    create(:role, :creator, :active, plan: plan, user: creator)

    if administrator
      create(:role, :administrator, :active, plan: plan, user: create(:user, org: org))
    end
    if editor
      create(:role, :editor, :active, plan: plan, user: create(:user, org: org))
    end
    if commenter
      create(:role, :commenter, :active, plan: plan, user: create(:user, org: org))
    end
    if reviewer
      create(:role, :reviewer, :active, plan: plan, user: create(:user, org: org))
    end
    plan
  end

end
