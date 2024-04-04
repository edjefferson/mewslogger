class CreateBoroughs < ActiveRecord::Migration[7.1]
  def change
    create_table :boroughs do |t|
      t.text :name

      t.timestamps
    end
  end
end
