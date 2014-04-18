class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password
      t.string :name
      t.string :access_token
      t.string :refresh_token
      t.string :expires_in

      t.timestamps
    end
  end
end
