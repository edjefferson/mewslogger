class CreateMewsImages < ActiveRecord::Migration[7.1]
  def change
    create_table :mews_images do |t|
      t.integer :mews_id
      t.timestamp :taken_at
      t.string :upload_at_timestamp
      t.float :lat
      t.float :lng
      t.string :image

      t.timestamps
    end
  end
end
