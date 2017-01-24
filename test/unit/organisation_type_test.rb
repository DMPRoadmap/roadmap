require 'test_helper'

class OrganisationTypeTest < ActiveSupport::TestCase
  
  setup do
    @organisation_type = OrganisationType.first
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not OrganisationType.new.valid?

    # Ensure the bar minimum and complete versions are valid
    a = OrganisationType.new(name: 'Tester')
    assert a.valid?, "expected the 'name' field to be enough to create an OrganisationType! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "can CRUD OrganisationType" do
    obj = OrganisationType.create(name: 'Testing CRUD')
    assert_not obj.id.nil?, "was expecting to be able to create a new OrganisationType! - #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.name = 'Testing an update'
    obj.save!
    obj.reload
    assert_equal 'Testing an update', obj.name, "Was expecting to be able to update the name of the OrganisationType!"
  
    assert obj.destroy!, "Was unable to delete the OrganisationType!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Organisation" do
    org = Organisation.new(name: 'Test Organisation')
    verify_has_many_relationship(@organisation_type, org, @organisation_type.organisations.count)
  end

end
