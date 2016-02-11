class Picture < ActiveRecord::Base
  belongs_to :event

  has_attached_file :img, styles: { thumb: "150x150>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :img, content_type: /\Aimage\/.*\Z/
end
