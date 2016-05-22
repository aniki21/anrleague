class CreateReportFlags < ActiveRecord::Migration
  def change
    create_table :report_flags do |t|
      t.integer :reporter_id
      t.integer :reportee_id
      t.string :reportee_type
      t.text :description
      t.string :aasm_state
      t.text :response
      t.integer :responder_id

      t.index :reportee_type
      t.index :aasm_state

      t.timestamps null: false
    end
  end
end
