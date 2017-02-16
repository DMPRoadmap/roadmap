require 'test_helper'

class RegionTest < ActiveSupport::TestCase

  setup do
    @region = Region.create(name: 'Test Super Region', abbreviation: 'TSR', description: 'Testing')
    
    @region.sub_regions = [Region.new(name: 'Test Sub Region 1'), Region.new(name: 'Test Sub Region 2')]
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Region.new.valid?
    
    # Ensure the bar minimum and complete versions are valid
    a = Region.new(name: 'Test Region')
    assert a.valid?, "expected the 'name' field to be enough to create an Region! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "name and abbreviation should be unique" do
    assert_not Region.new(name: 'Test Super Region').valid?, "expected that 'name' must be unique"
    assert_not Region.new(abbreviation: 'TSR').valid?, "expected that 'abbreviation' must be unique"
    
    assert_not Region.new(name: 'Test Super Region', abbreviation: '123').valid?, "expected that 'name' must be unique even if abbreviation is unique"
    assert_not Region.new(abbreviation: 'TSR', name: 'test super').valid?, "expected that 'abbreviation' must be unique even if name is unique"
  end
  
  # ---------------------------------------------------
  test "can CRUD Region" do
    obj = Region.create(name: 'Test Region')
    assert_not obj.id.nil?, "was expecting to be able to create a new Region: #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.abbreviation = 'ABC'
    obj.save!
    obj.reload
    assert_equal 'ABC', obj.abbreviation, "Was expecting to be able to update the text of the Region!"
  
    assert obj.destroy!, "Was unable to delete the Region!"
  end
    
  # Need to roll our own here because of the name of the relationship attributes
  # ---------------------------------------------------
  test "can manage has_and_belongs_to_many relationship with Region" do
    count = Region.first.sub_regions.count
    
    @region.super_region = Region.first
    @region.save!
    
    # Search the parent for the child
    assert Region.first.sub_regions.include?(@region), "was expecting the Region.sub_regions to contain the test region"
    assert_equal (count + 1), Region.first.sub_regions.count
  end
  
end