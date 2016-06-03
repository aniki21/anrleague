class AddCommentaryFieldsToGame < ActiveRecord::Migration
  def change
    add_column :games, :runner_commentary, :text
    add_column :games, :corp_commentary, :text
  end
end
