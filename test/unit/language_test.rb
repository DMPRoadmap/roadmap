require 'test_helper'

class LanguageTest < ActiveSupport::TestCase
  
  def setup
    @lang = Language.find_by(abbreviation: I18n.locale)
    @user = User.first
    @org = @user.org
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Language.new.valid?
    assert_not Language.new(name: 'Klingon').valid?
    assert_not Language.new(name: 'Klingon', description: 'Klingon', default_language: true).valid?
    
    assert Language.new(abbreviation: 'klgn').valid?
    assert Language.new(abbreviation: 'klgn', name: 'Klingon', description: 'Klingon', default_language: true).valid?
  end
  
  # ---------------------------------------------------
  test "abbreviation must be unique" do
    assert_not Language.new(abbreviation: Language.first.abbreviation).valid?
  end
  
  # ---------------------------------------------------
  test "can CRUD" do
    lang = Language.create(abbreviation: 'kg', name: 'Klingon')
    assert_not lang.id.nil?, "was expecting to be able to create a new Language : #{lang.errors.collect{ |e| e }.join(', ')}"

    lang.name = 'Imperial Klingon'
    lang.save!
    assert_equal 'Imperial Klingon', lang.reload.name, "was expecting the name to have been updated!"

    assert lang.destroy!, "Was unable to delete the Language!"
  end

  # ---------------------------------------------------
  test "can manage has_many relationship with Users" do
    verify_has_many_relationship(Language.last, User.last, Language.last.users.count)
  end

  # ---------------------------------------------------
  test "can manage has_many relationship with Organisations" do
    org = Org.create(name: 'testing', abbreviation: "TEST", links: {"org":[]})
    verify_has_many_relationship(Language.last, org, Language.last.orgs.count)
  end

end