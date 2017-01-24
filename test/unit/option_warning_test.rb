require 'test_helper'

class OptionWarningTest < ActiveSupport::TestCase
  include GlobalHelpers
  
  setup do
    @option = Option.first
    @organisation = Organisation.first
    
    @option_warning = OptionWarning.create(organisation: @organisation, option: @option, text: 'Testing')
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not OptionWarning.new.valid?
    assert_not OptionWarning.new(option: @option, organisation: @organisation).valid?, "expected the 'text' field to be required"

    # Ensure the bare minimum and complete versions are valid
    assert OptionWarning.new(text: 'Test', organisation: @organisation, option: @option).valid?, "expected the 'text', 'option' and 'organisation' fields to be enough to create an OptionWarning!"
  end

  # ---------------------------------------------------
  test "to_s returns the text of the option warning" do
    assert_equal @option_warning.text, @option_warning.to_s, "expected the to_s method to return the text field"
  end

  # ---------------------------------------------------
  test "can CRUD Guidance" do
    obj = OptionWarning.create(organisation: @organisation, option: @option, text: 'Testing option warnings')
    assert_not obj.id.nil?, "was expecting to be able to create a new OptionWarning!"

    obj.text = 'Testing an update'
    obj.save!
    obj.reload
    assert_equal 'Testing an update', obj.text, "Was expecting to be able to update the text of the OptionWarning!"
  
    assert obj.destroy!, "Was unable to delete the OptionWarning!"
  end

  # ---------------------------------------------------
  test "can manage belongs_to relationship with Organisation" do
    verify_belongs_to_relationship(@option_warning, @organisation)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Option" do
    verify_belongs_to_relationship(@option_warning, @option)
  end
end