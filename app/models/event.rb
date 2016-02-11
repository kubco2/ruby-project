class Event < ActiveRecord::Base
  validates :user, presence: true
  validates :date_at, presence: true
  belongs_to :user
  has_and_belongs_to_many :tags
  validates :tags, presence: { message: "must have at least one tag" }
  validates_associated :tags
  belongs_to :place
  validates_associated :place
  has_many :pictures
  has_attached_file :intropicture, styles: { thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :intropicture, content_type: /\Aimage\/.*\Z/
  has_many :subscriptions

  def tags_string
    tags.map(&:name).join(",")
  end

  def tags_string=(new_value)
    tag_names = new_value.split(/[,\s]+/)
    self.tags = tag_names.map { |name| Tag.where('name = ?', name).first || Tag.create(:name => name) }
  end

  def place_string
    place.nil? && "" || place.name
  end

  def place_string=(new_value)
    self.place = Place.where('name = ?', new_value).first || Place.create(:name => new_value)
  end

end
