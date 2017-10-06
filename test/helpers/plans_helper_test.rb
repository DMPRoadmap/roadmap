require 'test_helper'

class PlansHelperTest < ActionView::TestCase
  
  include Devise::Test::IntegrationHelpers
  
  UNKNOWN = I18n.t("helpers.project.columns.unknown")
  
  def setup
    scaffold_plan
    
    @user = User.last
    sign_in @user
  end
  
=begin
  # -----------------------------------------------------------------------
  test "plan_list_column_heading should return the localized text for the column heading" do
    cols = I18n.t("helpers.project.columns")
    
    cols.each do |k,v|
      assert plan_list_column_heading(k.to_s).include?(">#{I18n.t("helpers.project.columns.#{k}")}<"), "expected #{k} to return a column heading labeled #{v}"
    end
    
    assert plan_list_column_heading(["test1", 18, 'test3']).include?("Test1"), "expected the 1st item in the array if its a String"
    assert plan_list_column_heading([18, 'test3']).include?(UNKNOWN), "expected 'Unknown' if the 1st item in the array if is NOT a String"
    
    assert plan_list_column_heading(18).include?(UNKNOWN), "expected 'Unknown' if the value passed is not a String or an Array"
  end
  
  # -----------------------------------------------------------------------
  test "plan_list_column_body should return the localized text for the column heading" do
    cols = I18n.t("helpers.project.columns")
    
    assert plan_list_column_body(["non_link_name", "owner"], @plan).include?(@plan.title), "expected the 1st column to be used if passing in an Array"
    
    cols.each do |k,v|
      val = plan_list_column_body(k.to_s, @plan)

      if Plan.respond_to?(k)
        assert plan_list_column_body(k.to_s, @plan).include?(">#{@plan.send(k)}<"), "expected #{k} to return a column containing the Plan's value for that column. Instead got: #{val}"
        
      else
        if k == :owner
          assert val.include?(">#{@plan.users.first.name}<") || val.include?(t("helpers.me")), "expected :owner to return a column containing the Plan's value for that column or #{I18n.t("helpers.me")}. Instead got: #{val}"
        
        elsif k == :shared?
          assert val.include?(">Yes<") || val.include?(">No<"), "expected :shared? to return a column containing Yes/No. Instead got: #{val}"
        else
          
        end
      end
      
    end

    # Check different return options for the plan's owner
    plan = Plan.create(template: @template, title: 'No owner test')
    user = User.create(email: 'tester@example.com', firstname: 'Test', surname: 'Er', password: '123password')
    
    assert plan_list_column_body('owner', plan).include?(UNKNOWN), "expected Unknown if the column is 'owner' but the plan has no owner"

    plan.assign_creator(user.id)
    plan.save!
    plan.reload

    assert plan_list_column_body('owner', plan).include?(user.name), "expected the user's name if the column is 'owner' and the plan owner is not the current user"    
  end

  # TODO: 'custom_template' is part of the case logic in this method but it is unreachable 
  #       because both the plan and template settings objects use "Settings::Template". We 
  #       should remove it from logic
  # -----------------------------------------------------------------------
  test "plan_settings_indicator should return the correct export formatting settings" do
    assert plan_settings_indicator(@plan).include?(">#{I18n.t("helpers.settings.plans.default_formatting")}<"), "expected the default plan to use default export settings"
    
    @plan.settings(:export).formatting = {margin: {top: 5, bottom: 5, left: 5, right: 5},
                                          font_face: Settings::Template::VALID_FONT_FACES.last,
                                          font_size: 12}
    @plan.save!

    assert plan_settings_indicator(@plan).include?(">#{I18n.t("helpers.settings.plans.template_formatting")}<"), "expected the default plan to use default export settings"
    
    @plan.template.settings(:export).formatting = {margin: {top: 10, bottom: 10, left: 10, right: 10},
                                                   font_face: Settings::Template::VALID_FONT_FACES.first,
                                                   font_size: 11}
    @plan.save!
    
    assert plan_settings_indicator(@plan).include?(">#{I18n.t("helpers.settings.plans.template_formatting")}<"), "expected the default plan to use default export settings"
  end
=end
end
