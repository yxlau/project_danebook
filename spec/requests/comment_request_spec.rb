require 'rails_helper'

describe 'CommentsRequests' do
  let(:user){ create(:profile).user}
  let(:posting){ create(:post, user: user)}
  let(:comment){ create(:comment)}
  def create_comment(user)
    post post_comments_path(posting), params: { comment: attributes_for(:comment, user: user)  }
  end
  describe 'POST #create' do
    it 'requires logged in user' do
      expect{ create_comment(user) }.not_to change(Comment, :count)
    end
    context 'logged in' do
      before do
        login_as(user, scope: :user)
      end
      it 'creates a comment' do
        expect{  create_comment(user) }.to change(Comment, :count).by(1)
      end

    end
  end
  describe 'DELETE #destroy' do
    it 'requires user to be logged in' do
      comment
      expect{ delete comment_path(comment)}.not_to change(Comment, :count)
    end
    it 'can only delete own comment' do
      comment = create(:comment, user: create(:user))
      expect{ delete comment_path(comment)}.not_to change(Comment, :count)
    end
  end
end