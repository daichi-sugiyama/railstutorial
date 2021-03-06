require 'test_helper'
require 'securerandom'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name:"テストユーザ", email:"test@test.com", password: "pasword1234", password_confirmation: "pasword1234")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = SecureRandom.hex(51)
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = SecureRandom.hex(244) + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    @user.save
    duplicate_user = @user.dup
    assert_not duplicate_user.valid?
  end

  test "email validation same casedown" do
    email_string = "Ab6IX@test.com"
    @user.email = email_string
    @user.save
    assert_equal email_string.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "" * 5
    assert_not @user.valid?
  end

  test "associated microposts should be destroyed" do
    # userを保存
    @user.save
    # userに紐付いたmicropostを保存
    @user.microposts.create(content: "テストコンテンツ")
    # userを削除し、micropostも削除されていることを確認
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
end