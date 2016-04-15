require 'test_helper'

class GameSessionsControllerTest < ActionController::TestCase
  # Test filters
  test "should redirect not logged in user" do
    get :game_page
    assert_redirected_to signin_path
  end

  test "should kick user with no game" do
    sign_in users(:first_player)
    get :game_page
    assert_response :missing
  end
end
