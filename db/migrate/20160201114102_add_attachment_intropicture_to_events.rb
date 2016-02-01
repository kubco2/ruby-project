class AddAttachmentIntropictureToEvents < ActiveRecord::Migration
  def self.up
    change_table :events do |t|
      t.attachment :intropicture
    end
  end

  def self.down
    remove_attachment :events, :intropicture
  end
end
