class CreateBroadcasts < ActiveRecord::Migration
  def change
    create_table :broadcasts do |t|
      t.integer :user_id
      t.integer :presentation_id

      t.timestamps
    end
  end
end
