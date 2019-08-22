class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles, id: false do |t|
      t.string :id, primary_key: true, null: false
      t.string :name

      t.datetime :created_at, limit: 6
      t.datetime :updated_at, limit: 6
    end
  end
end
