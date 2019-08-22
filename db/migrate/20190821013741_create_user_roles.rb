class CreateUserRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :user_roles, id: false do |t|
      t.string :id, primary_key: true, null: false
      t.belongs_to :user, index: true, type: :string
      t.belongs_to :role, index: true, type: :string
    end
  end
end
