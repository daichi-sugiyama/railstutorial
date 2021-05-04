class User < ApplicationRecord
  attr_accessor :remember_token

  before_save { self.email.downcase! }

  validates(:name,presence:true,length: {maximum:50})
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates(:email,presence:true,length: {maximum:256}, format: { with: VALID_EMAIL_REGEX }, uniqueness: true)
  validates(:password,presence:true,length: {minimum: 6})
  has_secure_password

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを作成
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのため、ユーザーをデータベースに保存
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_token, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrue
  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
end
