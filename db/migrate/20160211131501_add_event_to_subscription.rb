class AddEventToSubscription < ActiveRecord::Migration
  def change
    add_reference :subscriptions, :event, index: true, foreign_key: true
  end
end
