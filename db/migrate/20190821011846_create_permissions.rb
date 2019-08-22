class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions, id: false do |t|
      t.string :id, primary_key: true, null: false
      t.string :name
    end
  end
end
