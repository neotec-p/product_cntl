class AuthController < ApplicationController
layout 'popup'

  def login
    unless session_get_user.blank?
      flash[:notice] = ""
      redirect_to(top_url)
      return
    end

    if request.post?
      begin
        user = User.authenticate(params[:id], params[:password])
        raise if user.blank?
        session_set_user(user)

        redirect_to(top_url)
      rescue => e
        flash.now[:notice] = t(:error_login)
      end
    end
  end

  def logout
      begin
        user = session[:user_id]
      rescue
      end

    session[:user_id] = nil
    session[:prm]     = nil
    reset_session

    redirect_to(root_url)
  end
  
protected
  def authorize
  end
end
