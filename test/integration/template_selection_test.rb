require 'test_helper'

class TemplateSelectionTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    # Need to clear the tables until we get seed.rb out of test_helper.rb
    Template.delete_all
    
    @funder = init_funder
    @institution = init_institution
    @organisation = init_organisation
    @funder2 = init_funder({ name: 'Funder 2', abbreviation: 'F2' })
    
    @researcher = init_researcher(@institution)
    @org_admin = init_org_admin(@institution)
    
    @funder_published_public_template = init_template(@funder, {
      title: 'Test Funder public Template', 
      published: true
    })
    @funder_published_private_template = init_template(@funder, {
      title: 'Test Funder private Template', 
      published: true
    })
    # funder templates are public by default on creation so set it to organisationally_visible afterward
    @funder_published_private_template.update!({ visibility: Template.visibilities[:organisationally_visible] })
    @funder_unpublished_template = init_template(@funder, {
      title: 'Test Funder unpublished Template', 
      published: false
    })
    @funder2_published_public_template = init_template(@funder2, {
      title: 'Test Funder 2 Template', 
      published: true
    })
    @org_published_private_template = init_template(@institution, {
      title: 'Test Org Template', 
      published: true
    })
    @default_published_private_template = init_template(@organisation, {
      title: 'Default Template',
      published: true,
      is_default: true
    })
  end
  
  # ----------------------------------------------------------
  test 'new plan gets published versions of templates not the latest version' do
    version = @org_published_private_template.generate_version!
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}"
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, "expected 1 template but got: #{json['templates'].collect{|h| h['title'] }.join(', ')}"
    assert_equal @org_published_private_template.id, json['templates'][0]['id'], 'expected the published version of the template'
  end

  # ----------------------------------------------------------
  test 'new plan gets default template when no funder or research org is specified' do
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=&plan[funder_id]="
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, "expected 1 template but got: #{json['templates'].collect{|h| h['title'] }.join(', ')}"
    assert_equal @default_published_private_template.id, json['templates'][0]['id'], 'expected the default template'
  end

  # ----------------------------------------------------------
  test 'new plan gets org template when a research org is specified but no funder is specified' do
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]="
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, "expected 1 template but got: #{json['templates'].collect{|h| h['title'] }.join(', ')}"
    assert_equal @org_published_private_template.id, json['templates'][0]['id'], 'expected 1 org template'
  end

  # ----------------------------------------------------------
  test 'new plan gets multiple org templates when a research org is specified but no funder is specified' do
    template2 = init_template(@institution, {
      title: 'Test Org Template 2', 
      published: true,
      is_default: false,
    })
    template2.update!(visibility: Template.visibilities[:organisationally_visible])
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]="
    json = JSON.parse(@response.body)
    assert_equal 2, json['templates'].size, "expected 2 templates but got: #{json['templates'].collect{|h| h['title'] }.join(', ')}"
    json['templates'].each{ |h| assert [@org_published_private_template.id, template2.id].include?(h['id']), 'expected the json to include only the 2 org templates' }
  end

  # ----------------------------------------------------------
  test 'new plan gets public funder template when no research org is specified' do
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, "expected 1 template but got: #{json['templates'].collect{|h| h['title'] }.join(', ')}"
    assert_equal @funder_published_public_template.id, json['templates'][0]['id'], 'expected the funder template'
  end

  # ----------------------------------------------------------
  test 'new plan gets multiple public funder templates when no research org is specified' do
    template2 = init_template(@funder, {
      title: 'Test Funder Template 2', 
      published: true,
      is_default: false,
      visibility: Template.visibilities[:publicly_visible]
    })
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)
    assert_equal 2, json['templates'].size, "expected 2 templates but got: #{json['templates'].collect{|h| h['title'] }.join(', ')}"
    json['templates'].each{ |h| assert [@funder_published_public_template.id, template2.id].include?(h['id']), 'expected the json to include only the 2 funder templates' }
  end
  
  # ----------------------------------------------------------
  test 'new plan gets both the public funder template when both research org and funder are specified' do
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, "expected 1 template but got: #{json['templates'].collect{|h| h['title'] }.join(', ')}"
    assert_equal @funder_published_public_template.id, json['templates'][0]['id'], 'expected the funder template'
  end

  # ----------------------------------------------------------
  test 'new plan gets the customized version of funder template when the specified research org has customized it' do
    customization = @funder_published_public_template.customize!(@institution)
    customization.update!(title: 'Customization test', published: true)
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, "expected 1 template but got: #{json['templates'].collect{|h| h['title'] }.join(', ')}"
    assert_equal customization.id, json['templates'][0]['id'], 'expected the customization of the funder template'
  end
    
  # ----------------------------------------------------------
  test 'plan gets choice between multiple funder templates when both research org and funder are specified and both the org and funder have multiple templates' do
    funder_template2 = init_template(@funder, { title: 'Funder template 2', published: true, visibility: Template.visibilities[:publicly_visible] })
    org_template2 = init_template(@institution, { title: 'Org template 2', published: true, visibility: Template.visibilities[:organisationally_visible] })
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)
    assert_equal 2, json['templates'].size, "expected 2 templates but got: #{json['templates'].collect{|h| h['title'] }.join(', ')}"
    json['templates'].each{ |h| assert [@funder.id, funder_template2.id].include?(h['id']), 'expected the json to include only the funder templates' }
  end
  
  # ----------------------------------------------------------
  test 'new plan gets default template when combination of specified funder and research org have no templates' do
    @org_published_private_template.destroy!
    @funder_published_public_template.destroy!
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]=#{@funder.id}"
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, "expected 1 template but got: #{json['templates'].collect{|h| h['title'] }.join(', ')}"
    assert_equal @default_published_private_template.id, json['templates'][0]['id'], 'expected the default template'
  end
  
  # ----------------------------------------------------------
  test 'new plan gets customized version of the default template if the research org has no template of its own but has customized the default template' do
    @org_published_private_template.destroy
    customization = @default_published_private_template.customize!(@institution)
    customization.update!(title: 'Default template customization test', published: true)
    sign_in @researcher
    get "#{org_admin_template_options_path}?plan[org_id]=#{@institution.id}&plan[funder_id]="
    json = JSON.parse(@response.body)
    assert_equal 1, json['templates'].size, "expected 1 template but got: #{json['templates'].collect{|h| h['title'] }.join(', ')}"
    assert_equal customization.id, json['templates'][0]['id'], "expected the customized version of the default template"
  end
end
