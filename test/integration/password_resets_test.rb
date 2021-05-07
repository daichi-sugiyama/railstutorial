require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path # /password_resets/#{token} にアクセス
    assert_template 'password_resets/new' # password_resets/new.html.erb 表示
    assert_select 'input[name=?]', 'password_reset[email]' # inputのnameが'password_reset[email]'のものをテスト
    # メールアドレスが無効の場合
    post password_resets_path, params: {password_reset: {email: ""}} # パラメータが無効なものをpost
    assert_not flash.empty? # flashメッセージが存在
    assert_template 'password_resets/new' # password_resets/new.html.erb 表示
    # メールアドレスが有効の場合
    post password_resets_path, params: {password_reset: {email: @user.email}}# パラメータが有効なものをpost
    assert_not_equal @user.reset_digest, @user.reload.reset_digest # 設定したreset_digestと、保存したreset_digestが異なることをテスト
    assert_equal 1, ActionMailer::Base.deliveries.size # メールが届いていることをテスト
    assert_not flash.empty? # flashメッセージが存在
    assert_redirected_to root_url # rootにリダイレクト

    # パスワード再設定フォームのテスト
    user = assigns(:user)
    # メールアドレスが無効
    get edit_password_reset_path(user.reset_token, email: "") # emailパラメータが無効のpost
    assert_redirected_to root_url # emailパラメータが無効のpost
    # activeが無効なユーザー
    user.toggle!(:activated) # activatedを反転
    get edit_password_reset_path(user.reset_token, email: user.email) # 正常な値をpost
    assert_redirected_to root_url # emailパラメータが無効のpost
    user.toggle!(:activated) # activatedを反転
    # メールアドレスが有効で、トークンが無効
    get edit_password_reset_path('worng token', email: user.email) # 正常な値をpost
    assert_redirected_to root_url # emailパラメータが無効のpost
    # メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email: user.email) # 正常な値をpost
    assert_template 'password_resets/edit' # password_resets/edit.html.erb 表示
    assert_select 'input[name=email][type=hidden][value=?]', user.email # emailのhiddenフォームの中にemailが存在
    
    # 無効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token), params: {email: user.email, 
      user: {password: "bazzfoo", password_confirmation: "hogegehogefoo"}}
      assert_select 'div#error_explanation'
    # パスワードが空
    patch password_reset_path(user.reset_token), params: {email: user.email, 
      user: {password: "", password_confirmation: ""}}
    assert_select 'div#error_explanation'
    # 有効なパスワードとパスワード確認(成功テスト)
    patch password_reset_path(user.reset_token), params: {email: user.email, 
      user: {password: "bazzfoo", password_confirmation: "bazzfoo"}}
    assert is_logged_in? # ログインを確認
    assert_not flash.empty? # flashメッセージが存在
    assert_redirected_to user # userにリダイレクト
  end

  test "expired token" do
    # get
    get new_password_reset_path # /password_resets/#{token} にアクセス
    # post
    post password_resets_path, params: {password_reset: {email: @user.email}}
    # patch
    user = assigns(:user)
    user.update_attribute(:reset_sent_at, Time.zone.now.ago(3.hour)) # reset_tokenを2時間に設定
    patch password_reset_path(user.reset_token), params: {email: user.email, 
      user: {password: "bazzfoo", password_confirmation: "bazzfoo"}}

    # アサーション
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
  end
end
