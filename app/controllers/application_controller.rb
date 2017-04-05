class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include ApplicationHelper

  rescue_from ActionController::RoutingError, with: :render_404

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def render_404
    render template: 'errors/errors', status: :not_found
  end
end
