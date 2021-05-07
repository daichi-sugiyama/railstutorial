require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show' #showが表示
    assert_select 'title', full_title(@user.name) # titleをアサーション
    assert_select 'h1', text: @user.name # h1をアサーション
    assert_select 'h1>img.gravatar'# imgにgravatarクラスをアサーション
    assert_match @user.microposts.count.to_s, response.body # microposts.countをアサーション
    @user.microposts.paginate(page: 1).each do |micropost|
      # micropost.contentをアサーション
      assert_match micropost.content, response.body
    end
  end
end
