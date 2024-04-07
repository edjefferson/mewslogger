class AddNotesToMews < ActiveRecord::Migration[7.1]
  def change
    add_column :mews, :notes, :text
  end
end
