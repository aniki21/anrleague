class AddAasmStateBanExpiryToUser < ActiveRecord::Migration
  def change
    add_column :users, :aasm_state, :string
    add_column :users, :ban_expires_at, :datetime

    add_index :users, :aasm_state
  end
end
