class CreateMewsSources < ActiveRecord::Migration[7.1]
  def change
    create_table :mews_sources do |t|
      t.integer :mews_id
      t.integer :os_open_name_id
      t.integer :osm_feature_id
      t.integer :price_paid_data_point_id

      t.timestamps
    end
  end
end
