require 'test_helper'

class TemplateTest < ActiveSupport::TestCase

  setup do
    # Need to clear the tables until we get seed.rb out of test_helper.rb
    Template.destroy_all
    
    @funder = init_funder
    @org = init_organisation
    @institution = init_institution
    @funder_org = init_funder_organisation
    
    @basic_template = init_template(@funder, published: true)
  end

  def init_full_template(template)
    phase = init_phase(template)
    section = init_section(phase)
    init_question(section)
    return template
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
  
  test "default values are properly set on template creation" do
    template = init_template(@funder)
    assert_equal false, template.published, 'expected a new template to not be published'
    assert_equal false, template.archived, 'expected a new template to not be archived'
    assert_not_nil template.family_id, 'expected a new template to have a family_id'
    assert_equal false, template.is_default, 'expected a new template to not be the default template'
    assert template.publicly_visible?, 'expected a new funder template to be publicly visible'

    tmplt = init_template(@org)
    tmplt2 = init_template(@funder_org)
    assert tmplt.organisationally_visible?, 'expected a new non-funder template to be organisationally visible'
    assert tmplt2.organisationally_visible?, 'expected a new non-funder template to be organisationally visible'
  end

  test "required fields are required" do
    assert_not Template.new.valid?
    assert_not Template.new(version: 1, title: 'Tester').valid?, "expected the 'org' field to be required"
    assert_not Template.new(org: @funder, version: 1).valid?, "expected the 'title' field to be required"
  end

  test "unarchived returns only unarchived templates" do
    # Create an unarchived and an archived template (set archived after init because it will default to false on creation)
    archived = init_template(@funder, { title: 'Archived Template' })
    archived.update_attributes(archived: true)
    results = Template.unarchived
    assert_equal 1, results.length, 'expected there to be only 1 unarchived template'
    assert_equal @basic_template, results.first, 'expected the correct template to have been returned'
  end
  
  test "archived returns only archived templates" do
    # Create an unarchived and an archived template (set archived after init because it will default to false on creation)
    archived = init_template(@funder, { title: 'Archived Template' })
    archived.update_attributes(archived: true)
    results = Template.archived
    assert_equal 1, results.length, 'expected there to be only 1 archived template'
    assert_equal archived, results.first, 'expected the correct template to have been returned'
  end
  
  test "able to determine the latest version number" do
    version2 = @basic_template.generate_version!
    version2.save!
    results = Template.latest_version_per_family(@basic_template.family_id)
    assert_equal 1, results.length, 'expected only one version to be returned for the specific family'
    assert_equal version2.version, results.first.version, 'expected the new version'
  end
  
  test "able to retrieve the latest version" do
    version2 = @basic_template.generate_version!
    version2.save!
    result = Template.latest_version(@basic_template.family_id)
    assert_equal 1, result.length, 'expected only one version to be returned'
    assert_equal version2, result.first, 'expected the new version'
  end

  test "able to version a template" do
    template = init_full_template(@basic_template)
    assert_equal 0, template.version, 'expected the initial template version to be zero'
    version2 = template.generate_version!
    assert_equal 1, version2.version, 'expected the version number to be one more than the original template\'s'
    assert_equal template.family_id, version2.family_id, 'expected the new version to have the same family_id'
    assert_equal template.visibility, version2.visibility, 'expected the new version to have the same visibility'
    assert_equal template.is_default, version2.is_default, 'expected the new version to have the same default flag'
    assert_equal false, version2.archived, 'expected the new version to no be archived'
    # All components were transferred over to the new version
    assert_equal template.phases.length, version2.phases.length, 'expected the new version to have the same number of phases'
    template.phases.each_with_index do |phase, idx|
      assert_phases_equal(phase, version2.phases[idx])
    end
  end

  test "#generate_copy! raises RuntimeError when a non Org object is passed" do
    init_full_template(@basic_template)
    exception = assert_raises(RuntimeError) do
      @basic_template.generate_copy!(nil)
    end
    assert_equal(_('generate_copy! requires an organisation target'), exception.message)
  end

  test "#generate_copy! creates a new copy of a template" do
    template = init_full_template(@basic_template)
    template.update_attributes(is_default: true, published: true) # Update these flags to verify that the copy sets them properly
    copy = template.generate_copy!(@institution)
    assert_not_equal template.id, copy.id, 'expecetd the copy to have a different id'
    assert_not_equal template.family_id, copy.family_id, 'expected the copy to have a different family id'
    assert_equal @institution, copy.org, 'expected the copy to have the correct Org'
    assert_equal 0, copy.version, 'expected the copy\'s version number to be zero'
    assert_not copy.published?, 'expected the copy to not be published'
    assert_not copy.is_default?, 'expected the copy to not be the default template'
    assert_equal 'organisationally_visible', copy.visibility, 'expected the visibility to be organisational'
    assert_equal 'Copy of %{template}' % { template: template.title }, copy.title, 'expected the template title to be "Copy of %{template}"'
    assert_equal template.description, copy.description, 'expected the template descriptions to match'
    assert_equal template.phases.length, copy.phases.length, 'expected the copy to have the same number of phases'
    template.phases.each_with_index do |phase, idx|
      assert_phases_equal(phase, copy.phases[idx])
    end
  end

  test "can properly determine if current template is the latest version" do
    assert @basic_template.latest?, 'expected the initial template to be the latest version'
    version2 = @basic_template.generate_version!
    version2.save!
    assert_not @basic_template.latest?, 'expected the initial template to no longer be the latest version'
    assert version2.latest?, 'expected the new version to be the latest version'
  end

  test "#customize! raises RuntimeError when a non Org object is passed" do
    init_full_template(@basic_template)
    exception = assert_raises(RuntimeError) do
      @basic_template.customize!(nil)
    end
    assert_equal(_('customize! requires an organisation target'), exception.message)
  end

  test "#customize! raises RuntimeError when the template belongs to a non funder" do
    template = init_template(@org, published: true)
    exception = assert_raises(StandardError) do
      template.customize!(@institution)
    end
  end
  
  test "#customize! allows user to customize the default template" do
    template = init_template(@org, published: true, is_default: true)
    customization = template.customize!(@institution)
    assert_not_nil(customization)
  end
  
  test "#customize! generates a new template" do
    template = init_full_template(@basic_template)
    customization = template.customize!(@institution)
    assert(customization.family_id.present?, 'expected a newly family_id value')
    assert_equal(template.family_id, customization.customization_of, 'expected the customization_of id to match the base template\'s family_id')
    assert_equal(0, customization.version, 'expected the initial customization version to be zero')
    assert_equal(@institution, customization.org, 'expected the customizatio\'s org to match the one specified')
    assert_not(customization.published, 'expected the customization to not be published')
    assert_equal('organisationally_visible', customization.visibility, 'expected the customization\'s visibility to be organisationally visible')
    assert_not(customization.is_default, 'expected the customization to not be the default template')

    # Following statements go further than checking that the instance method behaves adequately
    assert_equal template.phases.length, customization.phases.length, 'expected the customization to have the same number of phases as the base template'
    template.phases.each_with_index do |phase, idx|
      assert_phases_equal(phase, customization.phases[idx])
    end
  end
  test "#customize! is thread-safe and therefore only one customization_of/version/org_id record exists in the db" do
    template = init_template(@funder, published: true)
    await = true
    should_assert = true
    threads = 3.times.map do |i|
      Thread.new do
        while await do ; end
        begin
          template.customize!(@org)
        rescue ActiveRecord::StatementInvalid => e
          # SQLite only supports one writer at a time. (e.g. https://www.sqlite.org/rescode.html#busy)
          should_assert = false if e.message.include?("SQLite3::BusyException")
        end
      end
    end
    await = false
    threads.map(&:join)
    # ActiveRecord::Base.connection.adapter_name != 'SQLite'
    assert_equal(1, Template.where(customization_of: template.family_id, version: 0, org_id: @org.id).count) if should_assert
  end

  test "template customizations can be transferred after base template changes" do
    init_full_template(@basic_template)
    customization = @basic_template.customize!(@institution)
    first_question = customization.phases.first.sections.first.questions.first
    init_annotation(customization.org, first_question)
    customization.save!
  end

  test "base_org returns the current template org if the template is not customized" do
    assert_equal @basic_template.org, @basic_template.base_org, 'expected an uncustomized template to consider its own org the base_org'
  end
  test "base_org returns the parent template org if the template is customized" do
    customization = @basic_template.customize!(@institution)
    assert_equal @basic_template.org, customization.base_org, 'expected a customized template to consider the parent template\'s org the base_org'
  end

  test "#generate_version! raises RuntimeError when the template is not published" do
    template = init_template(@org, published: false)
    exception = assert_raises(RuntimeError) do
      template.generate_version!
    end
    assert_equal(_('generate_version! requires a published template'), exception.message)
  end

  test "#generate_version! creates a new version for a published and non-customised template" do
    template = init_template(@org, published: true)
    new_template = template.generate_version!
    assert_equal(@basic_template.version + 1, new_template.version)
    assert_not(new_template.published)
  end

  test "#generate_version! is thread-safe and therefore only one family_id/version record exists in the db" do
    template = init_template(@org, published: true)
    await = true
    should_assert = true
    threads = 3.times.map do |i|
      Thread.new do
        while await do ; end
        begin
          template.generate_version!
        rescue ActiveRecord::StatementInvalid => e
          # SQLite only supports one writer at a time. (e.g. https://www.sqlite.org/rescode.html#busy)
          should_assert = false if e.message.include?("SQLite3::BusyException")
        end
      end
    end
    await = false
    threads.map(&:join)
    assert_equal(1, Template.where(family_id: template.family_id, version: 1).count) if should_assert
  end

  test "#upgrade_customization! raises RuntimeError when the template is not a customisation of another template" do
    template = init_template(@org, published: true)
    exception = assert_raises(RuntimeError) do
      template.upgrade_customization!
    end
    assert_equal(_('upgrade_customization! requires a customised template'), exception.message)
  end

  test "#upgrade_customization! creates a new version" do
    customization = @basic_template.customize!(@institution)
    customization.published = true
    transferred = customization.upgrade_customization!
    assert_equal(customization.version + 1, transferred.version, 'expected the version number to have been incremented when the current cusomization was published')
    assert_equal(customization.family_id, transferred.family_id, 'expected the family_id to be retained when upgrade_customization! is called')
  end

  test "#upgrade_customization! appends modifiable phases to the new customisation" do
    init_full_template(@basic_template)
    customization = @basic_template.customize!(@institution)
    customization.phases << Phase.new(title: 'New customised phase', number: 2, modifiable: true)
    customization.phases << Phase.new(title: 'New customised phase 2', number: 3, modifiable: true)

    transferred = customization.upgrade_customization!
    assert_not_equal(customization.object_id, transferred.object_id, 'customization and transferred are distinct objects')
    assert_equal(3, transferred.phases.length, 'expected 3 phases after upgrading a customised template')
  end

  test "#upgrade_customization! appends modifiable sections into an unmodifiable phase" do
    init_full_template(@basic_template)
    customization = @basic_template.customize!(@institution)
    customization.phases.first.sections << Section.new(title: 'New customised section', number: 2, modifiable: true)
    customization.phases.first.sections << Section.new(title: 'New customised section 2', number: 3, modifiable: true)

    transferred = customization.upgrade_customization!
    assert_not_equal(customization.object_id, transferred.object_id, 'customization and transferred are distinct objects')
    assert_equal(3, transferred.phases.first.sections.length, 'expected 3 sections after upgrading a customised template')
  end

  test "#upgrade_customization! appends modifiable questions into an unmodifiable section" do
    init_full_template(@basic_template)
    customization = @basic_template.customize!(@institution)
    customization.phases.first.sections.first.questions << Question.new(text: 'New customised question', number: 2, modifiable: true)
    customization.phases.first.sections.first.questions << Question.new(text: 'New customised question 2', number: 3, modifiable: true)

    transferred = customization.upgrade_customization!
    assert_not_equal(customization.object_id, transferred.object_id, 'customization and transferred are distinct objects')
    assert_equal(3, transferred.phases.first.sections.first.questions.length, 'expected 3 questions after upgrading a customised template')
  end

  test "#upgrade_customization! appends annotations added to an unmodifiable question" do
    init_full_template(@basic_template)
    customization = @basic_template.customize!(@institution)
    customization.phases.first.sections.first.questions.first.annotations << 
      Annotation.new(text: 'New customised guidance', type: Annotation.types[:guidance], org: customization.org)
    customization.phases.first.sections.first.questions.first.annotations << 
      Annotation.new(text: 'New customised example_answer', type: Annotation.types[:example_answer], org: customization.org)

    @basic_template.phases.first.sections.first.questions.first.annotations <<
      Annotation.new(text: 'New funder guidance', type: Annotation.types[:guidance], org: @basic_template.org)
    @basic_template.phases.first.sections.first.questions.first.annotations <<
      Annotation.new(text: 'New funder example_answer', type: Annotation.types[:example_answer], org: @basic_template.org)

    transferred = customization.upgrade_customization!
    assert_not_equal(customization.object_id, transferred.object_id, 'customization and transferred are distinct objects')
    assert_equal(4, transferred.phases.first.sections.first.questions.first.annotations.length, 'expected 4 annotations after upgrading a customised template')
  end

  test "#generate_version? returns true when the template is published" do
    @basic_template.published = true
    assert(@basic_template.generate_version?)
  end

  test "#generate_version? returns false when the template is not published" do
    @basic_template.published = false
    assert_not(@basic_template.generate_version?)
  end

  test "#customize? returns false when no org is passed" do
    assert_not(@basic_template.customize?(nil))
  end

  test "#customize? returns false when the template is not owned by a funder or is not the default template" do
    template = init_template(@institution, { title: 'institutional template', is_default: false })
    assert_not template.customize?(@funder)
  end

  test "#customize? returns true when the org does not have a customization of the template" do
    assert(@basic_template.customize?(@institution))
  end

  test "#customize? returns false when the org has already a customization of the template" do
    @basic_template.customize!(@institution)
    assert_not(@basic_template.customize?(@institution))
  end

  test "#upgrade_customization? returns false when the template is not a customization of another template" do
    assert_not(@basic_template.upgrade_customization?)
  end

  test "#upgrade_customization? returns false when the template is already according to the latest published funder template" do
    @basic_template.published = true
    customization = @basic_template.customize!(@institution)
    assert_not(customization.upgrade_customization?)
  end

  test "#upgrade_customization? returns true when the template is stale, i.e a new version from funder has been published" do
    @basic_template.published = true
    customization = @basic_template.customize!(@institution)
    customization.created_at = customization.created_at.yesterday
    new_version = @basic_template.generate_version!
    new_version.published = true
    new_version.save!
    assert(customization.upgrade_customization?)
  end

  test "default template retains the correct flags when versioned" do
    @basic_template.update!({ org: @org, published: true, is_default: true, visibility: Template.visibilities[:publicly_visible] })
    new_version = @basic_template.generate_version!
    assert_not new_version.published?, 'expected the new version to not be published'
    assert new_version.is_default?, 'expected the new version to be flagged as the default template'
    assert new_version.publicly_visible?, 'expected the new version to be publicly visible'
  end
  
  test " a customization of the default template is not marked as the default" do
    @basic_template.update!({ org: @org, published: true, is_default: true, visibility: Template.visibilities[:publicly_visible] })
    customization = @basic_template.customize!(@institution)
    assert_not customization.published?, 'expected the customization to not be published'
    assert_not customization.is_default?, 'expected the customization to not be flagged as the default template'
    assert_not customization.publicly_visible?, 'expected the customization to not be publicly visible'
  end

  test "::find_or_generate_version! raises RuntimeError when attempting to retrieve a historical version for being modified" do
    @basic_template.generate_version!
    exception = assert_raises(RuntimeError) do
      Template.find_or_generate_version!(@basic_template)
    end
    assert_equal(_('A historical template cannot be retrieved for being modified'), exception.message)
  end

  test "::find_or_generate_version! does not generate a new version" do
    new_template = @basic_template.generate_version!
    template = Template.find_or_generate_version!(new_template)
    assert_equal(new_template, template)
  end

  test "::find_or_generate_version! generates a new version" do
    template = Template.find_or_generate_version!(@basic_template)
    assert_not_equal(@basic_template, template)
  end

  test "publishing a template automatically unpublishes other versions" do
    @basic_template.published = true
    @basic_template.save!
    v2 = @basic_template.generate_version!
    v2.published = true
    v2.save!
    assert v2.reload.published?, 'expected the new version to be published'
    assert_not @basic_template.reload.published?, 'expected the old version to be unpublished'
  end

  test "draft? returns false for a published template" do
    @basic_template.published = true
    assert_not @basic_template.draft?
  end
  
  test "draft? returns true for an unpublished version of a template that has a published version" do
    @basic_template.published = true
    version = @basic_template.generate_version!
    assert version.draft?
  end
  
  test "draft? returns false for a template that has no published versions" do
    @basic_template.published = true
    version = @basic_template.generate_version!
    @basic_template.update(published: false)
    assert_not version.draft?
  end
end
