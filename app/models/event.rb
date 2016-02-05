class Event < ActiveRecord::Base
  validates :user, presence: true
  validates :date_at, presence: true
  belongs_to :user
  has_and_belongs_to_many :tags
  validates :tags, presence: { message: "must have at least one tag" }
  validates_associated :tags

  def tags_string
    tags.map(&:name).join(",")
  end

  def tags_string=(new_value)
    tag_names = new_value.split(/[,\s]+/)
    self.tags = tag_names.map { |name| Tag.where('name = ?', name).first || Tag.create(:name => name) }
  end

end
