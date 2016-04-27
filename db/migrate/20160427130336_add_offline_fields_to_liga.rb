class AddOfflineFieldsToLiga < ActiveRecord::Migration
  def change
    add_column :ligas, :description_markdown, :text
    add_column :ligas, :description_html, :text
  end
end
