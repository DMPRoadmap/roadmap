require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  
  setup do
    @org = Org.first
    @template = Template.first
    @plan = Plan.create(title: 'Test Plan', template: @template, grant_number: 'Plan12345',
                        identifier: '000912', description: 'This is a test plan', 
                        principal_investigator: 'John Doe', principal_investigator_identifier: 'ABC',
                        data_contact: 'john.doe@example.com', visibility: 1, 
                        roles: [Role.new(user: User.last, creator: true)])
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Plan.new.valid?
    assert_not Plan.new(title: 'Testing').valid?, "expected the template field to be required"
    
    # Make sure that the Settings gem is defaulting the title for us
    assert Plan.new(template: @template).valid?, "expected the title field to have been set by default by the Settings gem"
    
    # Ensure the bare minimum and complete versions are valid
    a = Plan.new(title: 'Testing', template: @template)
    assert a.valid?, "expected the 'title', 'template' and at least one 'user' fields to be enough to create an Plan! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "a slug is properly generated when creating a record" do
    #p = Plan.create(title: 'Testing 123', template: @template, users: [User.last])
    #assert_equal "testing-123", p.slug
  end
  
  # ---------------------------------------------------
  test "has_sections returns false if there are NO published versions with sections" do
    # TODO: build out this test if the has_sections method is actually necessary
  end
  
  # ---------------------------------------------------
  test "can CRUD Plan" do
    obj = Plan.create(title: 'Testing CRUD', template: Template.where.not(id: @template.id).first, 
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
    tmplt = Template.create(org: @org, title: 'Testing relationship')
    verify_belongs_to_relationship(@plan, tmplt)
  end
  
end
