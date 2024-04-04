class CreateOsOpenNames < ActiveRecord::Migration[7.1]
  def change
    create_table :os_open_names do |t|
      t.text :os_id
      t.text :names_uri
      t.text :name1
      t.text :name1_lang
      t.text :name2
      t.text :name2_lang
      t.text :os_type
      t.text :local_type
      t.integer :geometry_x
      t.integer :geometry_y
      t.integer :most_detail_view_res
      t.integer :least_detail_view_res
      t.integer :mbr_xmin
      t.integer :mbr_ymin
      t.integer :mbr_xmax
      t.integer :mbr_ymax
      t.text :postcode_district
      t.text :postcode_district_uri
      t.text :populated_place
      t.text :populated_place_uri
      t.text :populated_place_type
      t.text :district_borough
      t.text :district_borough_uri
      t.text :district_borough_type
      t.text :county_unitary
      t.text :county_unitary_uri
      t.text :county_unitary_type
      t.text :region
      t.text :region_uri
      t.text :country
      t.text :country_uri
      t.text :related_spatial_object
      t.text :same_as_dbpedia
      t.text :same_as_geonames

      t.timestamps
    end
  end
end
