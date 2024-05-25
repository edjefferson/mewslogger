class CreateGazetteerEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :gazetteer_entries do |t|
      t.text :borough
      t.integer :usrn
      t.text :name
      t.text :match_name
      t.text :address1
      t.text :address2
      t.text :maintenace
      t.text :ownership
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end
