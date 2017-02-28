require 'test_helper'

module Settings
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
  
  end
end