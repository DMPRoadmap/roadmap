require 'test_helper'

class ThemeTest < ActiveSupport::TestCase

  setup do
    @theme = Theme.create(title: 'Test Theme', description: 'My test theme', locale: I18n.locale)
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Theme.new.valid?
    
    # Ensure the bare minimum are valid
    a = Theme.new(title: 'Tester')
    assert a.valid?, "expected the 'title' field to be enough to create an Theme! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "to_s returns the title" do
    assert_equal @theme.title, @theme.to_s
  end
  
  # ---------------------------------------------------
  test "can CRUD Theme" do
    obj = Theme.create(title: 'Tester')
    assert_not obj.id.nil?, "was expecting to be able to create a new Theme!"

    obj.description = 'Testing an update'
    obj.save!
    obj.reload
    assert_equal 'Testing an update', obj.description, "Was expecting to be able to update the description of the Theme!"
  
    assert obj.destroy!, "Was unable to delete the Theme!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Question" do
    question = Question.new(section: Section.first, text: 'Testing', number: 7)
    verify_has_many_relationship(@theme, question, @theme.questions.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Guidance" do
    guidance = Guidance.new(text: 'Testing')
    verify_has_many_relationship(@theme, guidance, @theme.guidances.count)
  end

end
