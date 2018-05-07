require 'test_helper'

class TemplateSelectionTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    # Need to clear the tables until we get seed.rb out of test_helper.rb
    Template.delete_all
    
    @funder = init_funder
    @institution = init_institution
    @organisation = init_organisation
    
    @researcher = init_researcher(@institution)
    @org_admin = init_org_admin(@institution)
    
    @funder_template = init_template(@funder, {
      title: 'Test Funder Template', 
      published: true,
      is_default: false,
      visibility: Template.visibilities[:publicly_visible]
    })
    @org_template = init_template(@institution, {
      title: 'Test Org Template', 
      published: true,
      is_default: false,
      visibility: Template.visibilities[:organisationally_visible]
    })
    @default_template = init_template(@organisation, {
      title: 'Default Template',
      published: true,
      is_default: true,
      visibility: Template.visibilities[:organisationally_visible]
    })
  end
  # ----------------------------------------------------------
  test 'new plan gets published versions of templates not the latest version' do
    version = @org_template.generate_version!
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}"
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, 'expected 1 template'
    assert_equal @org_template.id, json['templates'][0]['id'], 'expected the published version of the template'
  end

  # ----------------------------------------------------------
  test 'new plan gets default template when no funder or research org is specified' do
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=&plan[funder_id]="
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, 'expected 1 template'
    assert_equal @default_template.id, json['templates'][0]['id'], 'expected the default template'
  end

  # ----------------------------------------------------------
  test 'new plan gets org template when no funder is specified' do
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]="
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, 'expected 1 template'
    assert_equal @org_template.id, json['templates'][0]['id'], 'expected 1 org template'
  end

  # ----------------------------------------------------------
  test 'new plan gets funder template when no research org is specified' do
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, 'expected 1 template'
    assert_equal @funder_template.id, json['templates'][0]['id'], 'expected the funder template'
  end

  # ----------------------------------------------------------
  test 'new plan gets funder template when both research org and funder are specified' do
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, 'expected 1 template'
    assert json['templates'].collect{ |t| t['id'] }.include?(@funder_template.id), 'expected to find the funder template'
  end

  # ----------------------------------------------------------
  test 'new plan gets customized version of funder template when the research org has customized it' do
    customization = @funder_template.customize!(@institution)
    customization.update!(title: 'Customization test', published: true)
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, 'expected 1 template'
    assert_equal customization.id, json['templates'][0]['id'], 'expected the customized version of the funder template'
  end

  # ----------------------------------------------------------
  test 'new plan gets choice between multiple funder templates' do
    funder_template2 = init_template(@funder, { title: 'Funder template 2', published: true, visibility: Template.visibilities[:publicly_visible] })
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)
    assert_equal 2, json['templates'].size, 'expected 2 templates'
    json['templates'].each do |tmplt|
      assert [@funder_template.id, funder_template2.id].include?(tmplt['id']), 'expected both funder templates to be returned'
    end
  end
  
  # ----------------------------------------------------------
  test 'new plan gets choice between multiple funder templates when research org and funder are specified' do
    funder_template2 = init_template(@funder, { title: 'Funder template 2', published: true, visibility: Template.visibilities[:publicly_visible] })
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)
    assert_equal 2, json['templates'].size, 'expected 2 templates'
    json['templates'].each do |tmplt|
      assert [@funder_template.id, funder_template2.id].include?(tmplt['id']), 'expected both funder templates to be returned'
    end
  end
    
  # ----------------------------------------------------------
  test 'new plan gets choice between multiple research org templates when research org and no funder is specified' do
    org_template2 = init_template(@institution, { title: 'Org template 2', published: true, visibility: Template.visibilities[:organisationally_visible] })
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]="
    json = JSON.parse(@response.body)
    assert_equal 2, json['templates'].size, 'expected 2 templates'
    json['templates'].each do |tmplt|
      assert [@org_template.id, org_template2.id].include?(tmplt['id']), 'expected both org templates to be returned'
    end
  end
  
  # ----------------------------------------------------------
  test 'new plan gets default template when combination of specified funder and research org have no templates' do
    @org_template.destroy!
    @funder_template.destroy!
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, 'expected 1 template'
    assert_equal @default_template.id, json['templates'][0]['id'], 'expected the default template'
  end
  
  # ----------------------------------------------------------
  test 'new plan gets customized version of the default template if the research org has no template of its own' do
    @org_template.destroy
    customization = @default_template.customize!(@institution)
    customization.update!(title: 'Default template customization test', published: true)
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]="
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, 'expected 1 template'
    assert_equal customization.id, json['templates'][0]['id'], 'expected the customized version of the default template'
  end
end
