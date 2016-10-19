class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]

  def new
    sso_login
  end

  # def create
    # user = User.authenticate(params[:username], params[:password])

    # unless user.nil?
    #   if params[:remember_me] == 'true'
    #     user.refresh_remember_token
    #     cookies[:auth_token] = { :value => user.remember_token, :expires => 2.weeks.from_now }
    #   end

    #   session[:user_id] = user.id
    #   redirect_url = session.delete(:return_to) || folders_url
    #   redirect_to redirect_url, :only_path => true
    # else
    #   log_failed_sign_in_attempt(Time.now, params[:username], request.remote_ip)
    #   redirect_to new_session_url, :alert => t(:credentials_incorrect)
    # end
  # end

  def destroy
    current_user.forget_me
    cookies.delete :auth_token
    reset_session
    session[:user_id] = nil
    redirect_to new_session_url
  end

  private

  def log_failed_sign_in_attempt(date, username, ip)
    Rails.logger.error(
      "\nFAILED SIGN IN ATTEMPT:\n" +
      "=======================\n" +
      " Date: #{date}\n" +
      " Username: #{username}\n" +
      " IP address: #{ip}\n\n"
    )
  end

  protected

    def sso_login
      timestamp = Time.now.to_i.to_s
      token = gen_sso_token(current_host + timestamp + Settings.sso_token)
      sso_request = URI::HTTP.build(host: Settings.sso_host, port: (Settings.sso_port||80), path: "/users/sign_in",
        query: {
          from: current_server,
          timestamp: timestamp,
          token: token
        }.to_query
      )
      redirect_to sso_request.to_s
  end
end
