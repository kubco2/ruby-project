class Comment < ActiveRecord::Base
  validates :body, presence: true
  validates :user, presence: true
  validates :event, presence: true
  belongs_to :user
  belongs_to :event
end
