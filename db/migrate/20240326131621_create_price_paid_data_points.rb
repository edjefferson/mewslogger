class CreatePricePaidDataPoints < ActiveRecord::Migration[7.1]
  def change
    create_table :price_paid_data_points do |t|
      t.text :postcode
      t.text :address
      t.text :borough
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
