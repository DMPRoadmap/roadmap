require 'test_helper'

class PlanTest < ActiveSupport::TestCase

  setup do

    @org = Org.first
    @template = Template.first

    @creator = User.last
    @administrator = User.create!(email: 'administrator@example.com', password: 'password123')
    @editor = User.create!(email: 'editor@example.com', password: 'password123')
    @reader = User.create!(email: 'reader@example.com', password: 'password123')

    @plan = Plan.create(title: 'Test Plan', template: @template, grant_number: 'Plan12345',
                        identifier: '000912', description: 'This is a test plan',
                        principal_investigator: 'John Doe', principal_investigator_identifier: 'ABC',
                        data_contact: 'john.doe@example.com', visibility: :privately_visible)

    @plan.assign_creator(@creator.id)
    @plan.assign_administrator(@administrator.id)
    @plan.assign_editor(@editor.id)
    @plan.assign_reader(@reader.id) # AKA a commenter
    @plan.save!
    @plan.reload
  end

  # ---------------------------------------------------
  test "required fields are required" do
    # TODO: uncomment the validation on Plan and then retest this. The validations appear to be breaking the
    #       current plan save process in the controller, so determine why and fix.
=begin
    assert_not Plan.new.valid?
    assert_not Plan.new(title: 'Testing').valid?, "expected the template field to be required"

    # Make sure that the Settings gem is defaulting the title for us
    assert Plan.new(template: @template).valid?, "expected the title field to have been set by default by the Settings gem"

    # Ensure the bare minimum and complete versions are valid
    a = Plan.new(title: 'Testing', template: @template)
    assert a.valid?, "expected the 'title', 'template' and at least one 'user' fields to be enough to create an Plan! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
=end
  end


  # ---------------------------------------------------
  test "correctly creates a new answer" do
    q = @template.phases.first.sections.last.questions.last
    q.answers = []
    q.save!

    answer = @plan.answer(q.id)
    assert_equal nil, answer.id, "expected a new Answer"
    assert_equal q.default_value, answer.text, "expected the new Answer to use the Default Answer for the Question"
  end

  # ---------------------------------------------------
  test "correctly retrieves the answer for the question" do
    q = @template.phases.first.sections.last.questions.last
    answer = @plan.answer(q.id)
    answer.text = "testing"
    answer.save!

    answr = @plan.answer(q.id)
    assert_not answr.id.nil?, "expected the latest Answer"
    assert_equal "testing", answr.text, "expected the Answer returned to have the correct text"
  end

  # ---------------------------------------------------
  test "retrieves the selected guidance groups" do
    # Create a new theme and attach it to our template's question and a guidance group
    t = Theme.create!(title: 'Test A')
    q = @template.phases.first.sections.first.questions.first
    # This is to make the default guidance group created in callback to be published.
    # This ensures the selected gudiance group test passes with appropriate GuidanceGroup.
    gug = @org.guidance_groups.first
    gug.published = true
    gug.save!
    g = gug.guidances.first

    g.themes << t
    g.save
    q.themes << t
    q.save

    # Create a new guidance group and guidance that is attached to a theme but NOT used by our template
    t = Theme.create!(title: 'Test B')
    gg = GuidanceGroup.create!(name: 'Tester', org: @creator.org)
    g = Guidance.create!(text: 'Testing guidance', guidance_group: gg, themes: [t])

    pggs = @plan.get_guidance_group_options
    assert pggs.include?(gug)
    assert_not pggs.include?(gg)
  end

  # ---------------------------------------------------
  test "retrieves the available guidance for a the plan as a hash" do
    guidance_groups = GuidanceGroup.includes(guidances: :themes).where(published: true)
    @plan.guidance_groups << guidance_groups
    @plan.save!
    
    phase = @template.phases.first
    hash = @plan.guidance_by_question_as_hash
    
    phase.sections.includes(questions: :themes).each do |section|
      section.questions.each do |question|
        question.themes.each do |theme|
          guidance_groups.includes(guidances: :themes).each do |guidance_group|
            themed_guidance = guidance_group.guidances.collect{ |g| g.themes.collect(&:title) }.flatten.uniq
            if themed_guidance.include?(theme.title)
              assert hash[question.id][guidance_group.name][theme.title].length > 0, "expected themed guidance to appear for Question: #{question.id}, GuidanceGroup: #{guidance_group.name} and Theme: #{theme.title}"
            end
          end
        end
      end
    end
  end

  # ---------------------------------------------------
  test "checks whether the specified user can edit the plan" do
    @plan.assign_administrator(@administrator)
    @plan.assign_editor(@editor)
    @plan.assign_reader(@reader)

    # TODO: It seems like editable_by? should return true if the user is the creator or we've called assign_editor
    #       or assign_administrator. seems to be an issue with the assign_user private method on the Plan model
    #assert @plan.editable_by?(@creator), "expected the creator to NOT be able to edit the plan"
    #assert @plan.editable_by?(@editor), "expected the editor to be able to edit the plan"
    #assert @plan.editable_by?(@administrator), "expected the administrator to NOT be able to edit the plan"

    assert_not @plan.editable_by?(@reader), "expected the reader to NOT be able to edit the plan"
  end

  # ---------------------------------------------------
  test "checks whether the specified user can read the plan" do
    @plan.assign_administrator(@administrator)
    @plan.assign_editor(@editor)
    @plan.assign_reader(@reader)

    # TODO: It seems like readable_by? should return true if the user is the creator or we've called assign_editor
    #       or assign_administrator or assign_reader. seems to be an issue with the assign_user method on Plan
    #assert @plan.readable_by?(@creator), "expected the creator to NOT be able to read the plan"
    #assert @plan.readable_by?(@editor), "expected the editor to be able to read the plan"
    #assert @plan.readable_by?(@administrator), "expected the administrator to be able to read the plan"
    #assert @plan.readable_by?(@reader), "expected the reader to be able to read the plan"
  end

  # ---------------------------------------------------
  test "checks whether the specified user can administer the plan" do
    @plan.assign_administrator(@administrator)
    @plan.assign_editor(@editor)
    @plan.assign_reader(@reader)

    # TODO: It seems like creator should be able to administer their own plan or we have called assign_administrator
    #       seems to be an issue with the assign_user private method on the Plan model
    #assert @plan.administerable_by?(@creator), "expected the creator to NOT be able to administer the plan"
    #assert @plan.administerable_by?(@administrator), "expected the administrator to be able to administer the plan"

    assert_not @plan.administerable_by?(@editor), "expected the editor to NOT be able to administer the plan"
    assert_not @plan.administerable_by?(@reader), "expected the reader to NOT be able to administer the plan"
  end

  # ---------------------------------------------------
  test "checks that status returns the correct information" do
    q = 0
    @template.phases.first.sections.map{|s| q += s.questions.count }
    hash = @plan.status

    # Expecting the hash to look something like this:
    # -----------------------------------------------
    #{"num_questions"=>13,
    # "num_answers"=>0,
    # "sections"=>{
    #   1=>{"questions"=>[1, 2], "num_questions"=>2, "num_answers"=>0},
    #   2=>{"questions"=>[3], "num_questions"=>1, "num_answers"=>0}},
    # "questions"=>{
    #   1=>{"answer_id"=>nil, "answer_created_at"=>nil, "answer_text"=>nil,
    #       "answer_option_ids"=>nil, "answered_by"=>nil},
    #   2=>{"answer_id"=>nil, "answer_created_at"=>nil, "answer_text"=>nil,
    #       "answer_option_ids"=>nil, "answered_by"=>nil},
    #   3=>{"answer_id"=>nil, "answer_created_at"=>nil, "answer_text"=>nil,
    #       "answer_option_ids"=>nil, "answered_by"=>nil}},
    # "space_used"=>30}

    assert_equal q, hash["num_questions"], "expected the number of questions to match"

    @template.phases.first.sections.each do |s|
      assert_not hash["sections"][s.id].nil?, "expected section #{s.id} to be in sections portion"
      s.questions.each do |q|
        assert hash["sections"][s.id]["questions"].include?(q.id), "expected section #{s.id}, question #{q.id} to be in section portion"

        assert_not hash["questions"][q.id].nil?, "expected question #{q.id} to appear in the questions portion"
      end
    end
  end

  # ---------------------------------------------------
  test "checks that user is a properly assigned as a creator" do
    assert @plan.owned_by?(@creator), "expected the creator to be able to be the owner"
    assert @plan.administerable_by?(@creator), "expected the creator to be able to administer"
    assert @plan.editable_by?(@creator), "expected the creator to be able to edit"
    assert @plan.readable_by?(@creator), "expected the creator to be able to comment"
  end

  # ---------------------------------------------------
  test "checks that user is a properly assigned as a editor" do
    assert_not @plan.owned_by?(@editor), "expected the editor to NOT be the owner"
    assert_not @plan.administerable_by?(@editor), "expected the editor to NOT be able to administer"
    assert @plan.editable_by?(@editor), "expected the editor to be able to edit"
    assert @plan.readable_by?(@editor), "expected the editor to be able to comment"
  end

  # ---------------------------------------------------
  test "checks that user is a properly assigned as a commenter" do
    assert_not @plan.owned_by?(@reader), "expected the reader to NOT be the owner"
    assert_not @plan.administerable_by?(@reader), "expected the reader to NOT be able to administer"
    assert_not @plan.editable_by?(@reader), "expected the reader to NOT be able to edit"
    assert @plan.readable_by?(@reader), "expected the commenter to be able to comment"
  end

  # ---------------------------------------------------
  test "checks that user is a properly assigned as a administrator" do
    assert_not @plan.owned_by?(@administrator), "expected the adminstrator to NOT be the owner"
    assert @plan.administerable_by?(@administrator), "expected the adminstrator to be able to administer"
    assert @plan.editable_by?(@administrator), "expected the adminstrator to be able to edit"
    assert @plan.readable_by?(@administrator), "expected the adminstrator to be able to comment"
  end

  # ---------------------------------------------------
  test "checks that user is a properly assigned as a reviewer" do
    val = Role.access_values_for(:reviewer, :commenter).min
    usr = User.create(email: 'test@testing.org', password: 'testing1234')
    @plan.roles << Role.new(user: usr, access: val)
    @plan.save!
    assert @plan.reviewable_by?(usr), "expected the reviewer to be able to review"
    assert @plan.readable_by?(usr), "expected the reviewer to be able to comment"
  end
  
  # ---------------------------------------------------
  test "name returns the title" do
    assert_equal @plan.title, @plan.name
  end

  # ---------------------------------------------------
  test "owner returns the creator" do
    @plan.assign_creator(@creator)

    # TODO: Investigate whether or not this should pass. It seems logical that the creator should be the owner by
    #       default but perhaps there is a use-case for someone creating plans for another user
    #assert_equal @creator, @plan.owner, "expected the owner to match the creator"

    plan = Plan.create!(template: Template.last, title: 'Testing no creator', visibility: :is_test)
    assert plan.owner.nil?, "expected a new plan with no creator assigned to return nil"
  end

  # ---------------------------------------------------
  test "returns the shared roles" do
    plan = Plan.create!(template: Template.last, title: 'Testing no creator', visibility: :is_test)
    # plan created creator, admin and commenter roles (15, 14, 8)
    plan.assign_creator(@creator)
    Role.create(user: User.first, plan: plan, access: 14)
    Role.create(user: User.last, plan: plan, access: 8)
    # assert that the plan is shared with above roles and doesnt include owner
    assert_equal(plan.shared, true)
  end

  # ---------------------------------------------------
  test "checks that last edited matches the latest_update" do
    now = Time.new
    @template.phases.last.updated_at = now
    assert_equal now.to_date, @plan.last_edited
  end

  # ---------------------------------------------------
  test "can CRUD Plan" do
    obj = Plan.create(title: 'Testing CRUD', template: Template.where.not(id: @template.id).first, visibility: :is_test,
                      roles: [Role.new(user: User.last, creator: true)], description: "should change")
    assert_not obj.id.nil?, "was expecting to be able to create a new Plan! - #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.description = 'changed'
    obj.save!
    obj.reload
    assert_equal 'changed', obj.description, "Was expecting to be able to update the title of the Plan!"

    assert obj.destroy!, "Was unable to delete the Plan!"
  end

  # ---------------------------------------------------
  test "can manage has_many relationship with Answers" do
    a = Answer.new(user: User.last, plan: @plan, question: @plan.questions.first, text: 'Test!')
    verify_has_many_relationship(@plan, a, @plan.answers.count)
  end

  # ---------------------------------------------------
  test "can manage has_many relationship with Role" do
    role = Role.new(user: User.first, editor: true)
    verify_has_many_relationship(@plan, role, @plan.roles.count)
  end

  # ---------------------------------------------------
  test "can manage has_many relationship with ExportedPlan" do
    ep = ExportedPlan.create(format: ExportedPlan::VALID_FORMATS.last)
    verify_has_many_relationship(@plan, ep, @plan.exported_plans.count)
  end

  # ---------------------------------------------------
  test "can manage belongs_to relationship with Template" do
    plan = Plan.new(title: 'Tester', visibility: :is_test)
    verify_belongs_to_relationship(plan, Template.first)
  end
  
  # ---------------------------------------------------
  test "owner_and_coowners returns the correct users" do
    usrs = @plan.owner_and_coowners
    assert_equal 2, usrs.length, "expected only 2 users"
    usrs.each do |usr|
      assert [@creator, @administrator].include?(usr), "expected only the creator and co-owner but found #{usr.email}"
    end
  end
  
  # ---------------------------------------------------
  test "can request feedback" do
    scaffold_org_admin(@creator.org)
    
    @plan.request_feedback(@creator)
    assert @plan.feedback_requested, "expected the feedback flag to be set to true"
    assert @plan.reviewable_by?(@user), "expected the Org Admin to be a reviewer" 
  end

  # ---------------------------------------------------
  test "can complete feedback" do
    scaffold_org_admin(@creator.org)
    val = Role.access_values_for(:reviewer, :commenter).min
    @plan.feedback_requested = true
    @plan.roles << Role.new(user: @user, access: val)
    @plan.save!
    
    @plan.complete_feedback(@user)
    assert_not @plan.feedback_requested, "expected the feedback flag to be set to false"
    assert_not @plan.reviewable_by?(@user), "expected the Org Admin to no longer be a reviewer" 
  end
end
