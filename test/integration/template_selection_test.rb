require 'test_helper'

class TemplateSelectionTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    # Need to clear the tables until we get seed.rb out of test_helper.rb
    Template.delete_all
    
    @funder = init_funder
    @institution = init_institution
    
    @researcher = init_researcher(@institution)
    @org_admin = init_org_admin(@institution)
    
    @funder_template = init_template(@funder, {
      title: 'Test Funder Template', 
      published: true, 
      visibility: Template.visibilities[:publicly_visible]
    })
    @org_template = init_template(@institution, {
      title: 'Test Org Template', 
      published: true
    })
  end
  # ----------------------------------------------------------
  test 'plan gets published versions of templates not the latest version' do
    version = @org_template.generate_version!
    sign_in @researcher

    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}"
    json = JSON.parse(@response.body)

    assert_equal 1, json['templates'].size, 'expected 1 template'
    assert_equal @org_template.id, json['templates'][0]['id'], 'expected the published version of the template'
  end

  # ----------------------------------------------------------
  test 'plan gets generic template when no funder or research org is specified' do
    temp = init_template(@institution, { published: true, is_default: true })
    sign_in @researcher
    
    get "#{org_admin_template_options_path}?plan[org_id]="
    json = JSON.parse(@response.body)

    assert_equal 1, json['templates'].size, 'expected 1 template'
    assert_equal temp.id, json['templates'][0]['id'], 'expected the default template'
  end

  # ----------------------------------------------------------
  test 'plan gets org template when no funder is specified' do
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]="
    json = JSON.parse(@response.body)

    assert_equal 1, json['templates'].size, 'expected 1 template'
    assert_equal @org_template.id, json['templates'][0]['id'], 'expected 1 org template'
  end

  # ----------------------------------------------------------
  test 'plan gets funder template when no research org is specified' do
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=&plan[funder_id]=#{@funder.id}"

    json = JSON.parse(@response.body)

    assert_equal 1, json['templates'].size, 'expected 1 template'
    assert_equal @funder_template.id, json['templates'][0]['id'], 'expected the funder template'
  end

  # ----------------------------------------------------------
  test 'plan gets funder template when research org has not customized it' do
    sign_in @researcher

    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)

    assert_equal 1, json['templates'].size, 'expected 1 template'
    assert_equal @funder_template.id, json['templates'][0]['id'], 'expected the funder template'
  end

  # ----------------------------------------------------------
  test 'plan gets customized version of funder template when the research org has customized it' do
    customization = @funder_template.customize!(@institution)
    customization.update!(title: 'Customization test', published: true)
    sign_in @researcher

    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)
    
    assert_equal 1, json['templates'].size, 'expected 1 template'
    assert_equal customization.id, json['templates'][0]['id'], 'expected the customized version of the funder template'
  end

  # ----------------------------------------------------------
  test 'a list of templates is returned when the funder has multiple published templates' do
    funder_template2 = init_template(@funder, { title: 'Funder template 2', published: true, visibility: Template.visibilities[:publicly_visible] })
    sign_in @researcher

    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)

    assert_equal 2, json['templates'].size, 'expected 2 templates'
    json['templates'].each do |tmplt|
      assert [@funder_template.id, funder_template2.id].include?(tmplt['id']), 'expected both funder templates to be returned'
    end
  end
end
