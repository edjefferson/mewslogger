class CreateMews < ActiveRecord::Migration[7.1]
  def change
    create_table :mews do |t|
      t.text :name
      t.text :alt_name
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end
