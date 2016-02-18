class AddSenderToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :sender_id, :integer
    add_foreign_key :subscriptions, :users, column: "sender_id"
  end
end
