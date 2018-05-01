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
    assert_not Template.new(version: 1, title: 'Tester').valid?, "expected the 'org' field to be required"
    assert_not Template.new(org: @org, version: 1).valid?, "expected the 'title' field to be required"
    
    # Ensure the bare minimum and complete versions are valid
    a = Template.new(org: @org, title: 'Tester')
    assert a.valid?, "expected the 'org', 'version' and 'title' fields to be enough to create an Template! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end

  # ---------------------------------------------------
  test "family_ids scope only returns the dmptemplate_ids for the specific Org" do
    Org.all.each do |org|
      family_ids = Template.valid.all.pluck(:dmptemplate_id).uniq
      scoped = Template.dmptemplate_ids
      assert_equal family_ids.count, scoped.count
      
      family_ids.each do |id|
        assert scoped.include?(id), "expected the family_ids scope to contain #{id} for Org: #{org.id}"
      end
      scoped.each do |id|
        assert family_ids.include?(id), "expected #{id} to be a valid dmptemplate_id for Org: #{org.id}"
      end
    end
  end

  # ---------------------------------------------------
  test "current scope only returns the most recent version for each dmptemplate_id" do
    Org.all.each do |org|
      Template.dmptemplate_ids.each do |dmptemplate_id|
        latest = Template.where(dmptemplate_id: dmptemplate_id).order(updated_at: :desc).first
        
        assert_equal latest, Template.current(dmptemplate_id), "Expected the template.id #{latest.id} to be the current record for Org: #{org.id}, dmptemplate_id: #{dmptemplate_id}"
      end
    end
  end
  
  # ---------------------------------------------------
  test "published scope only returns the current published version for each dmptemplate_id" do
    Org.all.each do |org|
      Template.dmptemplate_ids.each do |dmptemplate_id|
        latest = Template.where(dmptemplate_id: dmptemplate_id, published: true).order(updated_at: :desc).first
        if latest.nil?
          "Expected the template to have never been published" 
        else
          assert_equal latest, Template.live(dmptemplate_id), "Expected the template.id #{latest.id} to be the published record for Org: #{org.id}, dmptemplate_id: #{dmptemplate_id}"
        end
      end
    end
  end
  
  # ---------------------------------------------------
  test "deep copy" do
    verify_deep_copy(@template, ['id', 'created_at', 'updated_at'])
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
    plan = Plan.new(title: 'Test Plan', visibility: :is_test)
    verify_has_many_relationship(@template, plan, @template.plans.count)
  end

  # ---------------------------------------------------
  test "can manage belongs_to relationship with Org" do
    tmplt = Template.new(title: 'My test', version: 1)
    verify_belongs_to_relationship(tmplt, @org)
  end

  test 'should be invalid when links is not a hash' do
    t = Template.new(title: 'My test', version: 1, org: @org)
    t.links = []
    refute(t.valid?)
    assert_equal(['A hash is expected for links'], t.errors.messages[:links])
  end

  test 'should be invalid when links hash does not have the expected keys' do
    t = Template.new(title: 'My test', version: 1, org: @org)
    t.links = { "foo" => [], "bar" => [] }
    refute(t.valid?)
    assert_equal(['A key funder is expected for links hash', 'A key sample_plan is expected for links hash'], t.errors.messages[:links])
  end

  test 'should be invalid when links hash keys are not compliant to object links format' do
    t = Template.new(title: 'My test', version: 1, org: @org)
    t.links = { "funder" => [{}], "sample_plan" => [{}] }
    refute(t.valid?)
    assert_equal(['The key funder does not have a valid set of object links', 'The key sample_plan does not have a valid set of object links'], t.errors.messages[:links])
  end

  test 'should be valid when links hash keys are compliant to object links format' do
    t = Template.new(title: 'My test', version: 1, org: @org)
    t.links = { "funder" => [{ "link" => "foo", "text" => "bar" }], "sample_plan" => [] }
    assert(t.valid?)
    assert_nil t.errors.messages[:links]
  end
  
  test 'should return the latest customizations for the Org' do
    tA = Template.create!(title: 'My test A', version: 0, org: @org)
    tB = Template.create!(title: 'My test B', version: 0, org: @org)
    tC = Template.create!(title: 'My test C', version: 0, org: @org)
    
    # Test 1 - Multiple versions
    cAv0 = Template.create!(title: 'My test customization A', version: 0, customization_of: tA.dmptemplate_id, org: Org.first)
    cAv1 = Template.deep_copy(cAv0)
    cAv1.update_attributes(version: 1)
    
    # Test 2 - Only one version
    cBv0 = Template.create!(title: 'My test customization B', version: 0, customization_of: tB.dmptemplate_id, org: Org.first)

    # Test 3 - Make sure it always returns the latest version regardless of published statuses
    cCv0 = Template.create!(title: 'My test customization C', version: 0, customization_of: tC.dmptemplate_id, org: Org.first)
    cCv1 = Template.deep_copy(cCv0)
    cCv1.update_attributes(version: 1, published: true)
    cCv2 = Template.deep_copy(cCv1)
    cCv2.update_attributes(version: 2)
    
    latest = Template.org_customizations([tA, tB, tC].collect(&:dmptemplate_id), Org.first.id)
    assert latest.include?(cAv1), 'expected to get customization A - version 1.'
    assert latest.include?(cBv0), 'expected to get customization B - version 0.'
    assert latest.include?(cCv2), 'expected to get customization C - version 2.'
  end
end
