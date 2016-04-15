module ApplicationHelper
  def render_404_page
    render file: 'public/errors.html.erb', status: 404
  end
end
