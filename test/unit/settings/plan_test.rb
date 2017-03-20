require 'test_helper'

module Settings
  class PlanTest < ActiveSupport::TestCase

    setup do
      @org = Org.last
    
      scaffold_plan
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
      assert(!@plan.settings(:export).value?)
      assert_equal(default_formatting, @plan.settings(:export).formatting)
    end

    # ---------------------------------------------------
    test "settings should use defined valid settings" do
      @plan.settings(:export).formatting = settings
      @plan.save!

      assert(@plan.settings(:export).value?)
      assert_equal(settings, @plan.settings(:export).formatting)
      assert_not_equal(default_formatting, @plan.settings(:export).formatting)
    end

    # ---------------------------------------------------
    test "setting negative margin should not be valid" do
      @margin = { top: -10, bottom: 10, left: 10, right: 10 }

      @plan.settings(:export).formatting = settings

      assert(!@plan.valid?)
      assert(!@plan.save)

      assert_equal(_('Margin cannot be negative'),
                   @plan.errors.messages[:'template.setting_objects.formatting'].first)

      @plan.reload
      assert_equal(default_formatting, @plan.settings(:export).formatting)
    end

    # ---------------------------------------------------
    test "setting unknown margin should not be valid" do
      @margin =  { top: 10, bottom: 10, left: 10, right: 10, top_left: 10 }

      @plan.settings(:export).formatting = settings

      assert(!@plan.valid?)
      assert(!@plan.save)

      assert_equal(_('Unknown margin. Can only be \'top\', \'bottom\', \'left\' or \'right\''),
                   @plan.errors.messages[:'template.setting_objects.formatting'].first)

      @plan.reload
      assert_equal(default_formatting, @plan.settings(:export).formatting)
    end

    # ---------------------------------------------------
    test "setting negative font-size should not be valid" do
      @font_size = -11

      @plan.settings(:export).formatting = settings

      assert(!@plan.valid?)
      assert(!@plan.save)

      assert_equal(_('Invalid font size'),
                   @plan.errors.messages[:"template.setting_objects.formatting"].first)

      @plan.reload

      assert_equal(default_formatting, @plan.settings(:export).formatting)
    end

    # ---------------------------------------------------
    test "setting unknown key should not be valid" do
      @plan.settings(:export).formatting = settings(foo: :bar)

      assert(!@plan.valid?)
      assert(!@plan.save)

      assert_equal(_('Unknown formatting setting'),
                   @plan.errors.messages[:'template.setting_objects.formatting'].first)

      @plan.reload

      assert_equal(default_formatting, @plan.settings(:export).formatting)
    end

    # ---------------------------------------------------
    test "not setting font_face should not be valid" do
      @plan.settings(:export).formatting = settings.reject {|k,v| k == :font_face }

      assert(!@plan.valid?)
      assert(!@plan.save)

      assert_equal(_('A required setting has not been provided'),
                   @plan.errors.messages[:'template.setting_objects.formatting'].first)

      @plan.reload

      assert_equal(default_formatting, @plan.settings(:export).formatting)
    end

    # ---------------------------------------------------
    test "not setting font_size should not be valid" do
      @plan.settings(:export).formatting = settings.reject {|k,v| k == :font_size }

      assert(!@plan.valid?)
      assert(!@plan.save)

      assert_equal(_('A required setting has not been provided'),
                   @plan.errors.messages[:'template.setting_objects.formatting'].first)

      @plan.reload

      assert_equal(default_formatting, @plan.settings(:export).formatting)
    end

    # ---------------------------------------------------
    test "not setting margin should not be valid" do
      @plan.settings(:export).formatting = settings.reject {|k,v| k == :margin }

      assert(!@plan.valid?)
      assert(!@plan.save)

      assert_equal(_('A required setting has not been provided'),
                   @plan.errors.messages[:'template.setting_objects.formatting'].first)

      @plan.reload

      assert_equal(default_formatting, @plan.settings(:export).formatting)
    end

    # ---------------------------------------------------
    test "setting non-hash as margin should not be valid" do
      @margin = :foo

      @plan.settings(:export).formatting = settings

      assert(!@plan.valid?)
      assert(!@plan.save)

      assert_equal(_('Margin value is invalid'),
                   @plan.errors.messages[:'template.setting_objects.formatting'].first)

      @plan.reload

      assert_equal(default_formatting, @plan.settings(:export).formatting)
    end

    # ---------------------------------------------------
    test "setting non-integer as font_size should not be valid" do
      @font_size = "foo"

      @plan.settings(:export).formatting = settings

      assert(!@plan.valid?)
      assert(!@plan.save)

      assert_equal(_('Invalid font size'),
                   @plan.errors.messages[:'template.setting_objects.formatting'].first)

      @plan.reload

      assert_equal(default_formatting, @plan.settings(:export).formatting)
    end

    # ---------------------------------------------------
    test "setting non-string as font_face should not be valid" do
      @font_face = 1

      @plan.settings(:export).formatting = settings

      assert(!@plan.valid?)
      assert(!@plan.save)

      assert_equal(_('Invalid font face'),
                   @plan.errors.messages[:'template.setting_objects.formatting'].first)

      @plan.reload

      assert_equal(default_formatting, @plan.settings(:export).formatting)
    end

    # ---------------------------------------------------
    test "setting unknown string as font_face should not be valid" do
      @font_face = 'Monaco, Monospace, Sans-Serif'

      @plan.settings(:export).formatting = settings

      assert(!@plan.valid?)
      assert(!@plan.save)

      assert_equal(_('Invalid font face'),
                   @plan.errors.messages[:'template.setting_objects.formatting'].first)

      @plan.reload

      assert_equal(default_formatting, @plan.settings(:export).formatting)
    end
  
  end
end