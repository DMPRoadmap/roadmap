<<<<<<< HEAD
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
=======
require 'test_helper'

class OrganisationTypeTest < ActiveSupport::TestCase
  def setup
    # OrganisationTypes MUST match those defined in the locale's magic strings file
    @organisation_type = organisation_types(I18n.t("magic_strings.organisation_types").first[0])
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not OrganisationType.new.valid?
    assert_not OrganisationType.new(description: 'testing').valid?
    
    assert OrganisationType.new(name: 'test').valid?
    assert OrganisationType.new(name: 'test', description: 'testing').valid?
  end
  
  # ---------------------------------------------------
  test "name must be unique" do
    assert_not OrganisationType.new(name: @organisation_type.name).valid?
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Organisations" do
    organisation = Org.new(name: 'test')
    verify_has_many_relationship(@organisation_type, organisation, 
                                 @organisation_type.organisations.count)
  end
  
  # ---------------------------------------------------
  test "can CRUD" do
    ot = OrganisationType.create(name: 'test', description: 'testing')
    assert_not ot.id.nil?, "was expecting to be able to create a new OrganisationType"

    ot.description = 'testing 2'
    ot.save!
    ot.reload
    assert_equal 'testing 2', ot.description, "Was expecting to be able to update the description of the OrganisationType!"
    
    assert ot.destroy!, "Was unable to delete the OrganisationType!"
  end
  
  # ---------------------------------------------------
  test "magic strings match the values in the database/fixtures" do
    I18n.t("magic_strings.organisation_types").each do |k,v|
      assert_not OrganisationType.find_by(name: v).nil?, "An OrganisationType called #{v} is defined in the magic strings section of the locale file, but no matching value exists in the datbase/fixtures!"
    end
  end
end
>>>>>>> final_schema
