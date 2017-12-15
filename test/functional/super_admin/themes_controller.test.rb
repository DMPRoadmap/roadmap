require 'test_helper'

class ThemesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.find_by(email: 'super_admin@example.com')
  end

  # index action tests
  test 'index action responds redirect when user is not super_admin' do
    get(super_admin_themes_path)
    assert_response :redirect
  end
  test 'index action responds success when user is super_admin' do
    sign_in @user
    get(super_admin_themes_path)
    assert_response :ok
  end

  # new action tests
  test 'new action responds redirect when user is not super_admin' do
    get(new_super_admin_theme_path)
    assert_response :redirect
  end
  test 'new action responds success when user is super_admin' do
    sign_in @user
    get(new_super_admin_theme_path)
    assert_response :ok
  end

  # create action tests
  test 'create action responds redirect when user is not super_admin' do
    post(super_admin_themes_path({ theme: { title: 'foo', description: 'bar' }}))
    assert_response :redirect
  end
  test 'create action responds redirect with flash alert for ActionController::ParameterMissing' do
    sign_in @user
    post(super_admin_themes_path({ foo: 'bar' }))
    assert_response :redirect
    assert_equal(_('Unable to save since theme parameter is missing'), flash[:alert])
  end
  test 'create action responds redirect with flash alert for ActiveRecord::RecordInvalid' do
    sign_in @user
    post(super_admin_themes_path({ theme: { description: 'bar' }}))
    assert_response :redirect
    assert_equal('unable to save your changes', flash[:alert])
  end
  test 'create action responds redirect with flash notice' do
    sign_in @user
    post(super_admin_themes_path({ theme: { title: 'foo', description: 'bar' }}))
    assert_response :redirect
    assert_equal(_('Theme created successfully'), flash[:notice])
  end

  # edit action tests
  test 'edit action responds redirect when user is not super_admin' do
    get(edit_super_admin_theme_path(id: Theme.first.id))
    assert_response :redirect
  end
  test 'edit action responds redirect when theme id does not exist' do
    sign_in @user
    get(edit_super_admin_theme_path(id: 'foo'))
    assert_response :redirect
    assert_equal(_('There is no theme associated with id %{id}') % { :id => 'foo'}, flash[:alert])
  end
  test 'edit action responds success when user is super_admin' do
    sign_in @user
    get(edit_super_admin_theme_path(id: Theme.first.id))
    assert_response :ok
  end
  # update action tests
  test 'update action responds redirect when user is not super_admin' do
    put(super_admin_theme_path({ id: Theme.first.id, theme: { title: 'foo', description: 'bar' }}))
    assert_response :redirect
  end
  test 'update action responds redirect with flash alert for ActionController::ParameterMissing' do
    sign_in @user
    put(super_admin_theme_path({ id: Theme.first.id }))
    assert_response :redirect
    assert_equal(_('Unable to save since theme parameter is missing'), flash[:alert])
  end
  test 'update action responds redirect with flash alert for ActiveRecord::RecordInvalid' do
    sign_in @user
    put(super_admin_theme_path({ id: Theme.first.id, theme: { title: '', description: 'bar' }}))
    assert_response :redirect
    assert_equal('unable to save your changes', flash[:alert])
  end
  test 'update action responds redirect when theme id does not exist' do
    sign_in @user
    put(super_admin_theme_path({ id: 'foo', theme: { title: 'bar', description: 'foobar' }}))
    assert_response :redirect
    assert_equal(_('There is no theme associated with id %{id}') % { :id => 'foo'}, flash[:alert])
  end
  test 'update action responds redirect with flash notice' do
    sign_in @user
    put(super_admin_theme_path({ id: Theme.first.id, theme: { title: 'foo', description: 'bar' }}))
    assert_response :redirect
    assert_equal(_('Theme updated successfully'), flash[:notice])
  end
  test 'destroy action responds redirect when user is not super_admin' do
    delete(super_admin_theme_path({ id: Theme.first.id }))
    assert_response :redirect
  end
  test 'destroy action responds redirect when theme id does not exist' do
    sign_in @user
    delete(super_admin_theme_path({ id: 'foo' }))
    assert_response :redirect
    assert_equal(_('There is no theme associated with id %{id}') % { :id => 'foo' }, flash[:alert])
  end
  test 'destroy action responds redirect with flash notice' do
    sign_in @user
    delete(super_admin_theme_path({ id: Theme.first.id }))
    assert_response :redirect
    assert_equal(_('Successfully deleted your theme'), flash[:notice])
  end
end