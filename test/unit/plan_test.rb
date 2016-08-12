require 'test_helper'

class PlanTest < ActiveSupport::TestCase
=begin
  def setup
    @plan = Plan.new.tap do |p|
      p.project = Project.new
    end
  end

  def settings(extras = {})
    {
      margin:    (@margin || { top: 10, bottom: 10, left: 10, right: 10 }),
      font_face: (@font_face || Settings::Dmptemplate::VALID_FONT_FACES.first),
      font_size: (@font_size || 11)
    }.merge(extras)
  end

  # settings

  test "no explicit settings should be Settings::Dmptemplate::DEFAULT_SETTINGS" do
    assert(!@plan.settings(:export).value?)
    assert_equal(Settings::Dmptemplate::DEFAULT_SETTINGS[:formatting], @plan.settings(:export).formatting)
  end

  test "no explicit settings with template settings should use template settings" do
    template = dmptemplates(:ahrc_template)
    template.settings(:export).update_attributes(formatting: settings)

    @plan.project.dmptemplate = template

    assert(!@plan.super_settings(:export).value?)
    assert(template.settings(:export).value?)

    assert_equal(settings, template.settings(:export).formatting)
    assert_equal(settings, @plan.settings(:export).formatting)
  end

  test "explicit settings with template settings should use plan settings" do
    template_settings = settings
    plan_settings = settings(font_size: 14)

    template = dmptemplates(:ahrc_template)
    template.settings(:export).update_attributes(formatting: template_settings)

    @plan.project.dmptemplate = template
    @plan.super_settings(:export).formatting = plan_settings
    @plan.save!
    @plan.reload

    assert(@plan.super_settings(:export).value?)
    assert(@plan.settings(:export).value?)
    assert(template.settings(:export).value?)

    assert_not_equal(plan_settings, template_settings)
    assert_equal(template_settings, template.settings(:export).formatting)
    assert_equal(plan_settings, @plan.settings(:export).formatting)
  end

  test "explicit settings should not affect other plans with same template" do
    template_settings = settings
    plan_settings = settings(font_size: 14)

    template = dmptemplates(:ahrc_template)
    template.settings(:export).update_attributes(formatting: template_settings)

    @plan.project.dmptemplate = template
    @plan.super_settings(:export).formatting = plan_settings
    @plan.save!
    @plan.reload

    other_plan = Plan.new.tap do |plan|
      plan.project = Project.new.tap {|p| p.dmptemplate = template }
    end

    other_plan.save!
    other_plan.reload

    assert(@plan.super_settings(:export).value?)
    assert(@plan.settings(:export).value?)
    assert(template.settings(:export).value?)

    assert_not_equal(plan_settings, other_plan.settings(:export).formatting)
    assert_equal(template_settings, other_plan.settings(:export).formatting)
  end
=end
end
