require 'test_helper'

class ListsControllerTest < ActionController::TestCase
  # ------------------------------------------------------------------
  # index – creates a list and redirects
  # ------------------------------------------------------------------
  test 'GET index creates a new list and redirects to its show page' do
    assert_difference 'List.count', 1 do
      get :index
    end
    assert_response :redirect
    assert_redirected_to show_list_path(token: List.last.token)
  end

  # ------------------------------------------------------------------
  # show
  # ------------------------------------------------------------------
  test 'GET show renders successfully for a valid token' do
    list = List.create!
    get :show, token: list.token
    assert_response :success
    assert_equal list.id, assigns(:list).id
  end

  test 'GET show redirects to root for an unknown token' do
    get :show, token: 'nonexistent_token'
    assert_redirected_to root_path
  end
end
