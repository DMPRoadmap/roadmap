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
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Visibility" do
    verify_belongs_to_relationship(@project, Visibility.first)
  end
  
end
