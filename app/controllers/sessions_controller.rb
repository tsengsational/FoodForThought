class SessionsController < ApplicationController

  def new
  end

  def create
    @user = User.find_by(user_name: params[:user_name])
    if @user && @user.authenticate(params[:password_digest])
      session[:user_id] = @user.id
      redirect_to user_path(@user)
      # change the redirect to something that makes sense.
    else
      redirect_to login_path
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path
  end

end
