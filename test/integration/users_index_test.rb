require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      if user.activated
        # 有効なユーザ
        assert_select 'a[href=?]', user_path(user), text: user.name
        unless user == @admin
          assert_select 'a[href=?]', user_path(user), text: 'delete'
        end
      else
        # 無効なユーザは表示されない
        assert_select 'a[href=?]', user_path(user), false
      end
    end
    # 【TODO】 削除をテスト
    # assert_difference 'User.count', -1 do
    #   delete user_path(@non_admin)
    # end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  test "show as user" do
    log_in_as(@admin)
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      # /user/#{id}にアクセス
      get user_path(user)
      if user.activated
        # 有効なユーザ
        assert_template 'users/show' # showが表示される
      else
        # 無効なユーザ
        assert_redirected_to root_url # root_urlにリダイレクト
      end
    end
  end
end
