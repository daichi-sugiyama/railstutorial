class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザー情報画面にリダイレクト
    else
      # エラーメッセージを作成
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destory
  end
end
