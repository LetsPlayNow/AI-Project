ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  # My helpers
  # =======================================================================
  # This is in sessions_helper.rb TODO repeating
  def sign_in(user)
    remember_token = User.new_remember_token
    cookies[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))

    return remember_token
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    if signed_in?
      current_user.update_attribute(:remember_token, User.encrypt(User.new_remember_token))
      cookies.delete(:remember_token)
      self.current_user = nil

    end
  end
end
