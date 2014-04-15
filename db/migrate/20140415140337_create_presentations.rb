class CreatePresentations < ActiveRecord::Migration
  def change
    create_table :presentations do |t|
      t.integer :user_id
      t.string :title
      t.text :description
      t.integer :status

      t.timestamps
    end
  end
end
