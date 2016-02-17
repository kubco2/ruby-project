class Subscription < ActiveRecord::Base
  validates :state, presence: true
  validates :user, presence: true
  validates :event, presence:true
  belongs_to :user
  belongs_to :sender, :class_name => "User"
  belongs_to :event
end
