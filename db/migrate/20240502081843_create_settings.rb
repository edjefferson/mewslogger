class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings do |t|
      t.text :key
      t.text :value

      t.timestamps
    end
  end
end
