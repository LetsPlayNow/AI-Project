class StaticPagesController < ApplicationController
  include StaticPagesHelper
  layout('application', only: :home)

  before_filter(:choose_language, except: :home)

  def home
    flash[:alert] = nil
  end

  def help
  end

  def funny_tutorial
  end

  def about
  end

  private
    # Выбрать язык в зависимости от параметров адресной строки (по-умолчанию: 'en')
    def choose_language
      @lang = params[:lang] || 'en'
      @lang = 'en' if (@lang != 'ru' && @lang != 'en')
      render_true_page
    end

    # Составить правильный адрес в зависимости от языка
    def render_true_page
      render full_page_name
    end
end
