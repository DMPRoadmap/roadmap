require 'test_helper'

class PagesControllerTest < ActionController::TestCase
=begin
  setup do
    @page = pages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create page" do
    assert_difference('Page.count') do
      post :create, page: { organisation_id: @page.organisation_id, body_text: @page.body_text, location: @page.location, menu: @page.menu, menu_position: @page.menu_position, public: @page.public, slug: @page.slug, target_url: @page.target_url, title: @page.title }
    end

    assert_redirected_to page_path(assigns(:page))
  end

  test "should show page" do
    get :show, id: @page
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @page
    assert_response :success
  end

  test "should update page" do
    put :update, id: @page, page: { organisation_id: @page.organisation_id, body_text: @page.body_text, location: @page.location, menu: @page.menu, menu_position: @page.menu_position, public: @page.public, slug: @page.slug, target_url: @page.target_url, title: @page.title }
    assert_redirected_to page_path(assigns(:page))
  end

  test "should destroy page" do
    assert_difference('Page.count', -1) do
      delete :destroy, id: @page
    end

    assert_redirected_to pages_path
  end
=end
end
