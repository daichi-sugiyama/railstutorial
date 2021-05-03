class ApplicationController < ActionController::Base
  include SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end
end
