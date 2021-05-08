class ApplicationController < ActionController::Base
  include SessionsHelper

  private
    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
        # ログインしていない場合
        store_location # アクセスしたURLをセッションに保存
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
