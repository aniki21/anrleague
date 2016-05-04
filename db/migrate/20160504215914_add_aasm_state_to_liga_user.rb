class AddAasmStateToLigaUser < ActiveRecord::Migration
  def change
    add_column :liga_users, :aasm_state, :string

    add_index :liga_users, :aasm_state
  end
end
