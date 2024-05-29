class AddIdsToMews < ActiveRecord::Migration[7.1]
  def change
    add_column :mews, :order_id, :text
    add_column :mews, :canonical_id, :text
  end
end
