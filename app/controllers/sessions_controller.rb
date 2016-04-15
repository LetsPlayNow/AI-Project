class SessionsController < ApplicationController
  before_filter :check_signed_in, only: [:new, :create]

  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if (@user && @user.authenticate(params[:session][:password]))
      sign_in @user
      redirect_to @user
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new' and return
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

  private
    # Запрещает пользователю попасть на страницу авторизации, если он уже вошел
    def check_signed_in
      if signed_in?
        redirect_to root_path
      end
    end
end
