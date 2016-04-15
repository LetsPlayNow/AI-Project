class StaticPagesController < ApplicationController
  before_filter :choose_language, except: [:home, :admin_page, :change_game_duration]
  before_filter :check_if_admin, only: [:admin_page, :change_game_duration]

  def home
  end

  def help
  end

  def funny_tutorial
  end

  def about
  end

  def support_project
  end

  def admin_page
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
      @action_name = params[:action]
      render @action_name + '_' + @lang
    end
end
