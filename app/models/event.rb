class Event < ActiveRecord::Base
  validates :user, presence: true
  validates :date_at, presence: true
  belongs_to :user
end
