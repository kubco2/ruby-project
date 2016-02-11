class AddAttachmentImgToPictures < ActiveRecord::Migration
  def self.up
    change_table :pictures do |t|
      t.attachment :img
    end
  end

  def self.down
    remove_attachment :pictures, :img
  end
end
