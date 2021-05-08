class Micropost < ApplicationRecord
  has_one_attached :image
  belongs_to :user
  default_scope -> { order(created_at: :desc) } #【メモ】ラムダ式（無名関数）

  validates(:user_id, presence:true)
  validates(:content, presence:true, length: {maximum:140})
end
