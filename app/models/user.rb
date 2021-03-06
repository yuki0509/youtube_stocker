class User < ApplicationRecord
  authenticates_with_sorcery!
  has_many :posts
  has_many :authentications, dependent: :destroy
  accepts_nested_attributes_for :authentications
  has_many :comments
  has_many :likes
  has_many :like_posts, through: :likes, source: :post

  mount_uploader :avatar, AvatarUploader

  enum role: { standard_user: 0, guest_user: 1 } 

  validates :password, length: { minimum: 8 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :email, presence: true, uniqueness: true
  validates :reset_password_token, uniqueness: true, allow_nil: true
  validates :avatar, presence: true

  def own?(object)
    id == object.user_id
  end
  
  def like(post)
    like_posts << post
  end

  def unlike(post)
    like_posts.destroy(post)
  end

  def like?(post)
    like_posts.include?(post)
  end
  
end
