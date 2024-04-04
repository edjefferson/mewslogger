class AddVisitedToMews < ActiveRecord::Migration[7.1]
  def change
    add_column :mews, :visited, :boolean
    add_column :mews, :visited_at, :timestamp
  end
end
