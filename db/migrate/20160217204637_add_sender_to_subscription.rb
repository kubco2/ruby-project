class AddSenderToSubscription < ActiveRecord::Migration
  def change
    add_reference :subscriptions, :sender, foreign_key: true
  end
end
