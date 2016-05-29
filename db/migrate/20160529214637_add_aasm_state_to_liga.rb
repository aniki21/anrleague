class AddAasmStateToLiga < ActiveRecord::Migration
  def change
    add_column :ligas, :aasm_state, :string, default: "active"
    add_index :ligas, :aasm_state
  end
end
