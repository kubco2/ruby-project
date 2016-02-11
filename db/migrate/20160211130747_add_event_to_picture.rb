class AddEventToPicture < ActiveRecord::Migration
  def change
    add_reference :pictures, :event, index: true, foreign_key: true
  end
end
