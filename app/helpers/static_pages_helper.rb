module StaticPagesHelper
  def full_page_name
    action_name + '_' + @lang
  end
end
