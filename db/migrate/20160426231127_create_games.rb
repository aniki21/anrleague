class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :league_id
      t.integer :season_id
      t.integer :runner_player_id
      t.integer :runner_identity_id
      t.integer :runner_agenda_points
      t.integer :corp_player_id
      t.integer :corp_identity_id
      t.integer :corp_agenda_points
      t.string :result

      t.timestamps null: false
    end
  end
end
