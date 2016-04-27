class AddAasmToSeason < ActiveRecord::Migration
  def change
    add_column :seasons, :aasm_state, :string
    add_index :seasons, :aasm_state
  end
end
