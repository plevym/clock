class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id:  false do |t|
      t.string :id, primary_key: true, null: false
      t.string :name
      t.string :username
      t.string :email
      t.string :password_digest

      t.datetime :created_at, limit: 6
      t.datetime :updated_at, limit: 6
    end
  end
end
