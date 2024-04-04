class AddLatLngToOsOpenName < ActiveRecord::Migration[7.1]
  def change
    add_column :os_open_names, :latitude, :float
    add_column :os_open_names, :longitude, :float
  end
end

