require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  test "should get show" do
    # Авторизованный
    user = User.first
    sign_in(user)

    get :show
    assert_response :success
  end
end
