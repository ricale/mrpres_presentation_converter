class CreateConvertedPresentations < ActiveRecord::Migration
  def change
    create_table :converted_presentations do |t|
      t.integer :presentation
      t.string :file_name
      t.integer :total_pages
      t.integer :status

      t.timestamps
    end
  end
end
