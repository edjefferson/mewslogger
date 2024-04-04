class CreateMewsBoroughs < ActiveRecord::Migration[7.1]
  def change
    create_table :mews_boroughs do |t|
      t.integer :mews_id
      t.integer :borough_id

      t.timestamps
    end
  end
end
