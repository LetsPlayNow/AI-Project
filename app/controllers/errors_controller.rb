class ErrorsController < ApplicationController
  # http://blog.grepruby.com/2015/04/custom-error-pages-with-rails-4.html
  # https://wearestac.com/blog/dynamic-error-pages-in-rails

  def not_found
    render :status => 404
  end

  def unacceptable
    render 'errors/internal_error', :status => 422
  end

  def internal_error
    render :status => 500
  end
end
