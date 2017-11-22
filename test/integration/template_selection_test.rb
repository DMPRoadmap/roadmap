require 'test_helper'

class TemplateSelectionTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    scaffold_template
    @template = Template.default

    @researcher = User.last

    scaffold_org_admin(@template.org)

    @funder = Org.find_by(org_type: 2)
    @funder_template = @funder.templates.where(published: true).first #Template.create(title: 'Funder template', org: @funder, migrated: false)
    # Template can't be published on creation so do it afterward
    @funder_template.published = true
    @funder_template.save

    @org = @researcher.org
    @org_template = Template.create(title: 'Org template', org: @org, migrated: false)
    # Template can't be published on creation so do it afterward
    @org_template.published = true
    @org_template.save
  end

  # ----------------------------------------------------------
  test 'plan gets publish versions of templates' do
    original_id = @template.id
    template = version_template(@template)

    sign_in @researcher

    post plans_path(format: :js), {plan: {org_id: @template.org.id}}
    assert_response :success
    assert @response.body.include?("$(\"#plan_template_id\").val(\"#{original_id}\");")
    assert_equal original_id, Template.live(@template.dmptemplate_id).id

    # Version the template again
    original_id = template.id
    template = version_template(template)

    # Make sure the published version is used
    post plans_path(format: :js), {plan: {org_id: @template.org.id}}
    assert_response :success
    assert @response.body.include?("$(\"#plan_template_id\").val(\"#{original_id}\");")
    assert_equal original_id, Template.live(@template.dmptemplate_id).id

    # Update the template and make sure the published version stayed the same
    sign_in @user
    put admin_update_template_path(template), {template: {title: "Blah blah blah"}}

    sign_in @researcher

    post plans_path(format: :js), {plan: {org_id: @template.org.id}}
    assert_response :success
    assert @response.body.include?("$(\"#plan_template_id\").val(\"#{original_id}\");")
    assert_equal original_id, Template.live(@template.dmptemplate_id).id
  end

  # ----------------------------------------------------------
  test 'plan gets generic template when no funder or org' do
    temp = Template.find_by(published: true, is_default: true)
    if temp.blank?
      @template.is_default = true
      @template.save!
      temp = @template
    end

    sign_in @researcher

    post plans_path(format: :js), {plan: {org_id: nil}}
    assert_response :success
    assert @response.body.include?("$(\"#plan_template_id\").val(\"#{temp.id}\");"), @response.body
  end

  # ----------------------------------------------------------
  test 'plan gets org template when no funder' do
    sign_in @researcher

    post plans_path(format: :js), {plan: {org_id: @org.id, funder_id: nil}}
    assert_response :success
    assert @response.body.include?("$(\"#plan_template_id\").val(\"#{@org_template.id}\");"), @response.body
  end

  # ----------------------------------------------------------
  test 'plan gets funder template when no org' do
    sign_in @researcher

    post plans_path(format: :js), {plan: {org_id: nil, funder_id: @funder.id}}
    assert_response :success
    assert @response.body.include?("$(\"#plan_template_id\").val(\"#{@funder_template.id}\");"), @response.body
  end

  # ----------------------------------------------------------
  test 'plan gets funder template when org has no customization' do
    sign_in @researcher

    post plans_path(format: :js), {plan: {org_id: @org.id, funder_id: @funder.id}}
    assert_response :success
    assert @response.body.include?("$(\"#plan_template_id\").val(\"#{@funder_template.id}\");"), @response.body
  end

  # ----------------------------------------------------------
  test 'plan gets customized version of funder template' do
    customization = Template.create(title: 'Customization', org: @org)
    # Template can't be published on creation so do it afterward
    customization.published = true
    customization.customization_of = @funder_template.dmptemplate_id
    customization.save

    sign_in @researcher

    post plans_path(format: :js), {plan: {org_id: @org.id, funder_id: @funder.id}}
    assert_response :success
    assert @response.body.include?("$(\"#plan_template_id\").val(\"#{customization.id}\");"), @response.body
  end

  # ----------------------------------------------------------
  test 'list of templates is returned when the funder has multiples' do
    funder_template2 = Template.create(title: 'Funder template 2', org: @funder)
    # Template can't be published on creation so do it afterward
    funder_template2.published = true
    funder_template2.save

    sign_in @researcher

    post plans_path(format: :js), {plan: {org_id: @org.id, funder_id: @funder.id}}
    assert_response :success
    assert_select "option", 3, "expected a dropdown with 2 templates and a 'please select' option"
    assert @response.body.include?("<option value=\\\"#{@funder_template.id}\\\">"), @response.body
    assert @response.body.include?("<option value=\\\"#{funder_template2.id}\\\">"), @response.body
  end


  private
    # ----------------------------------------------------------
    def version_template(template)
      put admin_publish_template_path(template)
      Template.current(template.dmptemplate_id)
    end
end
