class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :state

      t.timestamps null: false
    end

    add_index :subscriptions, :state
  end
end
