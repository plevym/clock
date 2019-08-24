class CreateRolePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :role_permissions, id: false do |t|
      t.string :id, primary_key: true, null: false
      t.belongs_to :role, index: true, type: :string
      t.belongs_to :permission, index: true, type: :string
    end
  end
end
