require 'test_helper'

class PhaseTest < ActiveSupport::TestCase
  
  setup do
    @organisation = Organisation.first
    @template = Dmptemplate.first
    @phase = Phase.create(title: 'Test Phase 1', number: 1, dmptemplate: @template)
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Phase.new.valid?
    assert_not Phase.new(title: 'Testing', number: 1).valid?, "expected the dmptemplate field to be required"
    assert_not Phase.new(number: 2, dmptemplate: @template).valid?, "expected the title field to be required"
    assert_not Phase.new(title: 'Testing', dmptemplate: @template).valid?, "expected the number field to be required"
    
    # Ensure the bar minimum and complete versions are valid
    a = Phase.new(title: 'Testing', dmptemplate: @template, number: 2)
    assert a.valid?, "expected the 'title', 'number' and 'dmptemplate' fields to be enough to create an Phase! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "a slug is properly generated when creating a record" do
    a = Phase.create(title: 'Testing 123', dmptemplate: @template, number: 2)
    assert_equal "testing-123", a.slug
  end
  
  # ---------------------------------------------------
  test "to_s returns the title" do
    assert_equal @phase.title, @phase.to_s
  end
  
  # ---------------------------------------------------
  test "latest_published_version returns the correct version" do
    assert_equal nil, @phase.latest_published_version, "expected nil if there is only one version and it was not specifically designated as published"

    4.times do |i|
      @phase.versions << Version.new(title: "Version #{i}", number: i, 
                                     published: (i == 3 ? true : false))
    end
    
    @phase.save!
    @phase.reload
    
    assert_equal 3, @phase.latest_published_version.number, "expected the last published version if there there were multiple published versions"
  end
  
  # ---------------------------------------------------
  test "has_sections returns false if there are NO published versions with sections" do
    # TODO: build out this test if the has_sections method is actually necessary
  end
  
  # ---------------------------------------------------
  test "can CRUD Phase" do
    obj = Phase.create(title: 'Testing CRUD', dmptemplate: @template, number: 4)
    assert_not obj.id.nil?, "was expecting to be able to create a new Phase! - #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.title = 'Testing an update'
    obj.save!
    obj.reload
    assert_equal 'Testing an update', obj.title, "Was expecting to be able to update the title of the Phase!"
  
    assert obj.destroy!, "Was unable to delete the Phase!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Versions" do
    v = Version.new(title: 'Test Version', number: 2)
    verify_has_many_relationship(@phase, v, @phase.versions.count)
  end

  # ---------------------------------------------------
  test "can manage belongs_to relationship with Dmptemplate" do
    tmplt = Dmptemplate.create(organisation: @organisation, title: 'Testing relationship')
    verify_belongs_to_relationship(@phase, tmplt)
  end
end
