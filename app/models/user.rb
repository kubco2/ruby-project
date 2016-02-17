class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "40x40>" }, default_url: ":style/no-profile-image.jpg"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  validates :name, presence: true
  validates :email, presence: true
  has_many :events
  has_many :subscriptions
  has_many :comments

end
