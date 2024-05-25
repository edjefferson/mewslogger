class AddGazetteerEntryToMewsSource < ActiveRecord::Migration[7.1]
  def change
    add_column :mews_sources, :gazetteer_entry_id, :integer
  end
end
