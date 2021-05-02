require 'test_helper'
require 'securerandom'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name:"テストユーザ",email:"test@test.com")
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
end