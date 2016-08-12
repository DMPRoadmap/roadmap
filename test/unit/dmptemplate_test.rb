require 'test_helper'

class DmptemplateTest < ActiveSupport::TestCase

  def setup
    @template = dmptemplates(:ahrc_template)
  end

  def settings(extras = {})
    {
      margin:    (@margin || { top: 10, bottom: 10, left: 10, right: 10 }),
      font_face: (@font_face || Settings::Dmptemplate::VALID_FONT_FACES.first),
      font_size: (@font_size || 11)
    }.merge(extras)
  end

  def default_formatting
    Settings::Dmptemplate::DEFAULT_SETTINGS[:formatting]
  end

  # ---------- settings ----------

  test "settings should use defaults if none defined" do
    assert(!@template.settings(:export).value?)
    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  test "settings should use defined valid settings" do
    @template.settings(:export).formatting = settings
    @template.save!

    assert(@template.settings(:export).value?)
    assert_equal(settings, @template.settings(:export).formatting)
    assert_not_equal(default_formatting, @template.settings(:export).formatting)
  end

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

  test "setting unknown key should not be valid" do
    @template.settings(:export).formatting = settings(foo: :bar)

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.unknown_key'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload

    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  test "not setting font_face should not be valid" do
    @template.settings(:export).formatting = settings.reject {|k,v| k == :font_face }

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.missing_key'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload

    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  test "not setting font_size should not be valid" do
    @template.settings(:export).formatting = settings.reject {|k,v| k == :font_size }

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.missing_key'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload

    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

  test "not setting margin should not be valid" do
    @template.settings(:export).formatting = settings.reject {|k,v| k == :margin }

    assert(!@template.valid?)
    assert(!@template.save)

    assert_equal(I18n.t('helpers.settings.plans.errors.missing_key'),
                 @template.errors.messages[:'setting_objects.formatting'].first)

    @template.reload

    assert_equal(default_formatting, @template.settings(:export).formatting)
  end

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

  # ---------- templates_org_type ----------
  test "templates_org_type returns all published" do
    OrganisationType.find_each do |org_type|
      result_templates = Dmptemplate.templates_org_type(org_type.name)
      my_list = Array.new
      org_type.organisations.each do |org|
        my_list += org.dmptemplates
      end
      my_list.each do |template|
        if template.published
          assert_includes(result_templates, template, "Template: #{template.title}} of type #{org_type.name}, not returned by templates_org_type")
        end
      end
    end
  end

  # ---------- funders_templates ----------
  test "funders_templates returns all funder organisation templates" do
    result_templates = Dmptemplate.funders_templates
    funder_templates = OrganisationType.find_by(name: "funder").organisations do |org|
      org.dmptemplates.each do |template|
        assert_includes( result_templates, template, "Funder Template: #{template.title} not included in result of funders_templates")
      end
    end
  end

  # ---------- own_institutional_templates ----------
  test "own_institutional_templates returns all templates belonging to given org_id" do
    Organisation.find_each do |org|
      result_templates = Dmptemplate.own_institutional_templates(org.id)
      org.dmptemplates.each do |template|
        assert_includes(result_templates, template, "Template: #{template.title} not returned by own_institutional_templates")
      end
    end
  end

  # ---------- funders_and_own_templates ----------
  test "funders_and_own_templates returns all funder and own given org_id templates" do
    Organisation.find_each do |org|
      result_templates = Dmptemplate.funders_and_own_templates(org.id)
      org.dmptemplates.each do |template|
        assert_includes(result_templates, template, "Template #{template.title} not returned by funders and own templates")
      end
    end
    funder_templates = OrganisationType.find_by(name: "funder").organisations do |org|
      org.dmptemplates.each do |template|
        assert_includes( result_templates, template, "Funder Template: #{template.title} not included in result of funders_and_own_templates")
      end
    end
  end

  # ---------- org_type ----------
  test "org_type properly returns the name of the template's organisation's type" do
    Dmptemplate.find_each do |template|
      assert_equal( template.org_type, template.organisation.organisation_type.name, "Template: #{template.title} returned #{template.org_type}, instead of #{template.organisation.organisation_type.name}")
      end
  end

  # ---------- has_customisations? ----------
  test "has_customisations? correctly identifies if a given org has customised the template" do
    # TODO: Impliment after understanding has_customisations
    flunk
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


end
