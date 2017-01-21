require 'test_helper'

class DmptemplateTest < ActiveSupport::TestCase

  setup do
    @template = Dmptemplate.first

    @organisation = Organisation.first
  end

  def settings(extras = {})
    {margin:    (@margin || { top: 10, bottom: 10, left: 10, right: 10 }),
     font_face: (@font_face || Settings::Dmptemplate::VALID_FONT_FACES.first),
     font_size: (@font_size || 11)
    }.merge(extras)
  end

  def default_formatting
    Settings::Dmptemplate::DEFAULT_SETTINGS[:formatting]
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Dmptemplate.new.valid?
    assert_not Dmptemplate.new(title: 'Testing tmeplate').valid?, "expected the 'organisation' field to be required"
    assert_not Dmptemplate.new(organisation: @organisation).valid?, "expected the 'title' field to be required"
    
    # Ensure the bar minimum and complete versions are valid
    a = Dmptemplate.new(organisation: @organisation, title: 'Testing tmeplate')
    assert a.valid?, "expected the 'title' and 'organisation' fields to be enough to create an Dmptemplate! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "to_s method returns the title" do
    assert_equal @template.title, @template.to_s
  end
  

  # ---------- settings ----------
  # ---------------------------------------------------
  test "settings should use defaults if none are defined" do
    assert(!@template.settings(:export).value?)
    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  # ---------------------------------------------------
  test "settings should use defined valid settings" do
    @template.settings(:export).formatting = settings
    @template.save!

    assert(@template.settings(:export).value?)
    assert_equal(settings, @template.settings(:export).formatting)
    assert_not_equal(default_formatting, @template.settings(:export).formatting)
  end

  # ---------------------------------------------------
  test "setting negative margin should not be valid" do
    @margin = { top: -10, bottom: 10, left: 10, right: 10 }

    @template.settings(:export).formatting = settings

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.negative_margin'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload
    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  # ---------------------------------------------------
  test "setting unknown margin should not be valid" do
    @margin =  { top: 10, bottom: 10, left: 10, right: 10, top_left: 10 }

    @template.settings(:export).formatting = settings

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.unknown_margin'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload
    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  # ---------------------------------------------------
  test "setting negative font-size should not be valid" do
    @font_size = -11

    @template.settings(:export).formatting = settings

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.invalid_font_size'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload

    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  # ---------------------------------------------------
  test "setting unknown key should not be valid" do
    @template.settings(:export).formatting = settings(foo: :bar)

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.unknown_key'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload

    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  # ---------------------------------------------------
  test "not setting font_face should not be valid" do
    @template.settings(:export).formatting = settings.reject {|k,v| k == :font_face }

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.missing_key'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload

    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  # ---------------------------------------------------
  test "not setting font_size should not be valid" do
    @template.settings(:export).formatting = settings.reject {|k,v| k == :font_size }

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.missing_key'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload

    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  # ---------------------------------------------------
  test "not setting margin should not be valid" do
    @template.settings(:export).formatting = settings.reject {|k,v| k == :margin }

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.missing_key'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload

    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  # ---------------------------------------------------
  test "setting non-hash as margin should not be valid" do
    @margin = :foo

    @template.settings(:export).formatting = settings

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.invalid_margin'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload

    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  # ---------------------------------------------------
  test "setting non-integer as font_size should not be valid" do
    @font_size = "foo"

    @template.settings(:export).formatting = settings

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.invalid_font_size'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload

    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  # ---------------------------------------------------
  test "setting non-string as font_face should not be valid" do
    @font_face = 1

    @template.settings(:export).formatting = settings

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.invalid_font_face'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload

    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  # ---------------------------------------------------
  test "setting unknown string as font_face should not be valid" do
    @font_face = 'Monaco, Monospace, Sans-Serif'

    @template.settings(:export).formatting = settings

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.invalid_font_face'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload

    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  # ---------- has_customisations? ----------
  test "has_customisations? correctly identifies if a given org has customised the template" do
    # TODO: Impliment after understanding has_customisations

  end

  # ---------- has_published_versions? ----------
  test "has_published_versions? correctly identifies published versions" do
    Dmptemplate.find_each do |template|
      template.phases.each do |phase|
        unless phase.latest_published_version.nil?
          assert(template.has_published_versions? , "there was a published version of phase: #{phase.title}")
        end
      end
    end
  end

  # ---------------------------------------------------
  test "can CRUD Template" do
    tmplt = Dmptemplate.create(organisation: @organisation, title: 'Testing tmeplate')
    assert_not tmplt.id.nil?, "was expecting to be able to create a new Dmptemplate!"

    tmplt.description = 'Testing an update'
    tmplt.save!
    tmplt.reload
    assert_equal 'Testing an update', tmplt.description, "Was expecting to be able to update the description of the Dmptemplate!"
  
    assert tmplt.destroy!, "Was unable to delete the Dmptemplate!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Phase" do
    phase = Phase.new(title: 'Test Phase', number: 2)
    verify_has_many_relationship(@template, phase, @template.phases.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Project" do
    project = Project.new(title: 'Test Project', organisation: @organisation)
    verify_has_many_relationship(@template, project, @template.projects.count)
  end

  # ---------------------------------------------------
  test "can manage has_many relationship with GuidanceGroup" do
    grp = GuidanceGroup.new(name: 'Test Group', organisation: @organisation)
    verify_has_many_relationship(@template, grp, @template.guidance_groups.count)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Organisation" do
    verify_belongs_to_relationship(@template, @organisation)
  end
  
end
