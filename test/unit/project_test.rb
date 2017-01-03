require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  setup do
    @project = Project.new({
      title: 'My Test Project',
      dmptemplate: Dmptemplate.first,
      organisation: Organisation.first
    })
  end
  
  # ----------------------------------------------------------------------------
  test "is_public flag should be false if is_test is true" do
    @project.is_public = true
    @project.save!
    assert_equal true, @project.is_public?, "expected the is_public flag to initially be true"
    
    @project.is_test = true
    assert_equal false, @project.is_public?, "expected the is_public flag to switch to false"
  end
  
  # ----------------------------------------------------------------------------
  test "is_test flag should be false if is_public is true" do
    @project.is_test = true
    @project.save!
    assert_equal true, @project.is_test?, "expected the is_test flag to initially be true"
    
    @project.is_public = true
    assert_equal false, @project.is_test?, "expected the is_test flag to switch to false"
  end
  
end
