class CreateOsmFeatures < ActiveRecord::Migration[7.1]
  def change
    create_table :osm_features do |t|
      t.text :feature_type
      t.float :osm_id
      t.text :address
      t.float :latitude
      t.float :longitude
      t.text :borough
      t.text :tags

      t.timestamps
    end
  end
end
