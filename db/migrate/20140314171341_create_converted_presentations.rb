class CreateConvertedPresentations < ActiveRecord::Migration
  def change
    create_table :converted_presentations do |t|
      t.integer :presentation_id
      t.string :file_name
      t.integer :pages

      t.timestamps
    end
  end
end
