class AddIsActualMewsToMews < ActiveRecord::Migration[7.1]
  def change
    add_column :mews, :actual_mews, :boolean
  end
end
