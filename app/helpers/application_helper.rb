module ApplicationHelper
  def not_found
    redirect_to errors_not_found_path
  end

  def internal_error
    redirect_to errors_internal_error_path
  end
end
