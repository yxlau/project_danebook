class Post < ApplicationRecord
  belongs_to :user
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy
  validates :body, presence: true

  include Reusable

  def liked_by(id)
    ! self.likes.where('user_id = ?', id).blank?
  end

  def post_likes(current_user)
    return '' unless self.likes_count
    msg = ''
    if self.liked_by(current_user.id)
      msg += 'You'
      remaining_likes = self.likes.where('user_id IS NOT ?', current_user.id).order('created_at DESC')
      case
      when self.likes_count == 1
        msg += ' like this'
      when self.likes_count == 2
        msg += ' and ' + remaining_likes.first.user.full_name + 'like this'
      when self.likes_count == 3
        msg += ', ' + remaining_likes.first.user.full_name + ' ' + 'and' + remaining_likes.second.user.full_name + ' like this'
      when self.likes_count > 3
        msg += ', ' + remaining_likes.first.user.full_name + ' and ' + (self.likes_count - 3).to_s + ' others like this'
      end
    else
      likes = self.likes.includes(:user)
      case
      when self.likes_count == 1
        msg += likes.first.user.full_name + ' likes this'
      when self.likes_count == 2
        msg += likes.first.user.full_name + ' and ' + likes.second.user.full_name + ' like this'
      else
        msg += self.likes_count.to_s + ' likes'.pluralize(self.likes_count) if self.likes_count > 0
      end
    end
    msg
  end


end