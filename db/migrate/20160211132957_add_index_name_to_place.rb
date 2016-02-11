class AddIndexNameToPlace < ActiveRecord::Migration
  def change
    add_index :places, :name
  end
end
