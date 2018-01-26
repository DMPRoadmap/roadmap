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
    @funder_template.visibility = Template.visibilities[:publicly_visible]
    @funder_template.save

    @org = @researcher.org
    @org_template = Template.create(title: 'Org template', org: @org, migrated: false)
    # Template can't be published on creation so do it afterward
    @org_template.published = true
    @org_template.visibility = Template.visibilities[:organisationally_visible]
    @org_template.save
  end

  # ----------------------------------------------------------
  test 'plan gets publish versions of templates' do
    original_id = @template.id
    template = version_template(@template)

    sign_in @researcher

    get "#{org_admin_template_options_path}?plan[org_id]=#{@template.org_id}"
    assert_response :success
    json = JSON.parse(@response.body)

    assert_equal 1, json['templates'].size
    assert_equal original_id, json['templates'][0]['id']
    assert_equal original_id, Template.live(@template.dmptemplate_id).id

    # Version the template again
    original_id = template.id
    template = version_template(template)

    # Make sure the published version is used
    get "#{org_admin_template_options_path}?plan[org_id]=#{@template.org_id}"
    assert_response :success
    json = JSON.parse(@response.body)

    assert_equal 1, json['templates'].size
    assert_equal original_id, json['templates'][0]['id']
    assert_equal original_id, Template.live(@template.dmptemplate_id).id

    # Update the template and make sure the published version stayed the same
    sign_in @user
    put org_admin_template_path(template), {template: {title: "Blah blah blah"}}

    sign_in @researcher

    get "#{org_admin_template_options_path}?plan[org_id]=#{@template.org_id}"
    assert_response :success
    json = JSON.parse(@response.body)

    assert_equal 1, json['templates'].size
    assert_equal original_id, json['templates'][0]['id']
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
    get "#{org_admin_template_options_path}?plan[org_id]="
    assert_response :success
    json = JSON.parse(@response.body)

    assert_equal 1, json['templates'].size
    assert_equal @template.id, json['templates'][0]['id']
  end

  # ----------------------------------------------------------
  test 'plan gets org template when no funder' do
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@org.id}&plan[funder_id]="

    assert_response :success
    json = JSON.parse(@response.body)

    assert_equal 1, json['templates'].size
    assert_equal @org_template.id, json['templates'][0]['id']
  end

  # ----------------------------------------------------------
  test 'plan gets funder template when no org' do
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=&plan[funder_id]=#{@funder.id}"

    assert_response :success
    json = JSON.parse(@response.body)

    assert_equal 1, json['templates'].size
    assert_equal @funder_template.id, json['templates'][0]['id']
  end

  # ----------------------------------------------------------
  test 'plan gets funder template when org has no customization' do
    sign_in @researcher

    get "#{org_admin_template_options_path}?plan[org_id]=#{@org.id}&plan[funder_id]=#{@funder.id}"
    assert_response :success
    json = JSON.parse(@response.body)

    assert_equal 2, json['templates'].size
    assert_equal @funder_template.id, json['templates'][0]['id']
  end

  # ----------------------------------------------------------
  test 'plan gets customized version of funder template' do
    customization = Template.create(title: 'Customization', org: @org)
    # Template can't be published on creation so do it afterward
    customization.published = true
    customization.visibility = Template.visibilities[:organisationally_visible]
    customization.customization_of = @funder_template.dmptemplate_id
    customization.save

    sign_in @researcher

    get "#{org_admin_template_options_path}?plan[org_id]=#{@org.id}&plan[funder_id]=#{@funder.id}"
    assert_response :success
    json = JSON.parse(@response.body)

    assert_equal 2, json['templates'].size
    assert_equal customization.id, json['templates'][0]['id']
  end

  # ----------------------------------------------------------
  test 'list of templates is returned when the funder has multiples' do
    funder_template2 = Template.create(title: 'Funder template 2', org: @funder)
    # Template can't be published on creation so do it afterward
    funder_template2.published = true
    funder_template2.visibility = Template.visibilities[:publicly_visible]
    funder_template2.save

    sign_in @researcher

    get "#{org_admin_template_options_path}?plan[org_id]=#{@org.id}&plan[funder_id]=#{@funder.id}"
    assert_response :success
    json = JSON.parse(@response.body)

    assert_equal 3, json['templates'].size
    assert_equal @funder_template.id, json['templates'][0]['id']
    assert_equal funder_template2.id, json['templates'][1]['id']
  end


  private
    # ----------------------------------------------------------
    def version_template(template)
      get publish_org_admin_template_path(template)
      Template.current(template.dmptemplate_id)
    end
end
