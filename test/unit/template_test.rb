require 'test_helper'

class TemplateTest < ActiveSupport::TestCase

  setup do
    @org = Org.last
    
    scaffold_template
  end

  def settings(extras = {})
    {margin:    (@margin || { top: 10, bottom: 10, left: 10, right: 10 }),
     font_face: (@font_face || Settings::Template::VALID_FONT_FACES.first),
     font_size: (@font_size || 11)
    }.merge(extras)
  end

  def default_formatting
    Settings::Template::DEFAULT_SETTINGS[:formatting]
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Template.new.valid?
    assert_not Template.new(org: @org, title: 'Tester').valid?, "expected the 'version' field to be required"
    assert_not Template.new(version: 1, title: 'Tester').valid?, "expected the 'org' field to be required"
    assert_not Template.new(org: @org, version: 1).valid?, "expected the 'title' field to be required"
    
    # Ensure the bare minimum and complete versions are valid
    a = Template.new(org: @org, version: 1, title: 'Tester')
    assert a.valid?, "expected the 'org', 'version' and 'title' fields to be enough to create an Template! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end

  # ---------------------------------------------------
  test "deep copy" do
    verify_deep_copy(@template, ['id', 'created_at', 'updated_at', 'slug'])
  end

  # ---------- has_customisations? ----------
  test "has_customisations? correctly identifies if a given org has customised the template" do
    @template.phases.first.modifiable = false
    assert @template.has_customisations?(@org.id, @template), "expected the template to have customisations if it's phase is NOT modifiable"

    @template.phases.first.modifiable = true
    assert_not @template.has_customisations?(@org.id, @template), "expected the template to NOT have customisations if it's phase is modifiable"
    
    @template.phases << Phase.new(title: 'New phase test', modifiable: false)
    assert @template.has_customisations?(@org.id, @template), "expected the template to have customisations if all of its phases is NOT modifiable"
    
    @template.phases.last.modifiable = true
    assert_not @template.has_customisations?(@org.id, @template), "expected the template to NOT have customisations if one of its phases is modifiable"
  end

  
  # ---------------------------------------------------
  test "can CRUD Template" do
    tmplt = Template.create(org: @org, version: 1, title: 'Tester')
    assert_not tmplt.id.nil?, "was expecting to be able to create a new Template!"

    tmplt.description = 'Testing an update'
    tmplt.save!
    tmplt.reload
    assert_equal 'Testing an update', tmplt.description, "Was expecting to be able to update the description of the Template!"
  
    assert tmplt.destroy!, "Was unable to delete the Template!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Phase" do
    phase = Phase.new(title: 'Test Phase', number: 2)
    verify_has_many_relationship(@template, phase, @template.phases.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Plan" do
    plan = Plan.new(title: 'Test Plan')
    verify_has_many_relationship(@template, plan, @template.plans.count)
  end

  # ---------------------------------------------------
  test "can manage belongs_to relationship with Org" do
    tmplt = Template.new(title: 'My test', version: 1)
    verify_belongs_to_relationship(tmplt, @org)
  end

end
