class SessionsController < ApplicationController
  def new
    session[:return_to] = params[:return_to] if params[:return_to]
  end

  def create
    if (auth = request.env["omniauth.auth"])
      user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
      session[:user_id] = user.id
      session[:access_token] = auth["credentials"]["token"]
      redirect_to root_url
    else
      user = User.find_by_name(params[:name])
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        if session[:return_to]
          redirect_to session[:return_to]
          session[:return_to] = nil
        else
          redirect_to root_url
        end
      else
        flash.now.alert = "Email or password is invalid"
        render "new"
      end
    end
  end

  def destroy
    session[:user_id] = nil
    session[:access_token] = nil
    redirect_to login_url
  end
end
