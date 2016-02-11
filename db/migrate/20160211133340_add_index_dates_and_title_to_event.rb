class AddIndexDatesAndTitleToEvent < ActiveRecord::Migration
  def change
    add_index :events, :date_at
    add_index :events, :date_to
    add_index :events, :title
  end
end
