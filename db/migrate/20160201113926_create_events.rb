class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.datetime :date_at
      t.datetime :date_to
      t.string :title
      t.text :description

      t.timestamps null: false
    end
  end
end
