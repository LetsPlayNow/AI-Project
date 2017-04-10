require 'test_helper'

class ErrorsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  test "should get not_found" do
    get :not_found
    assert_response :not_found
  end

  test "should get unacceptable" do
    get :unacceptable
    assert_response :unprocessable_entity
  end

  test "should get internal_error" do
    get :internal_error
    assert_response :internal_server_error
  end

end
