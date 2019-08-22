class CreateTimeChecks < ActiveRecord::Migration[5.2]
  def change
    create_table :time_checks, id: false do |t|
      t.string :id, primary_key: true, null: false
      t.belongs_to :user, index: true, type: :string

      t.datetime :created_at, limit: 6
      t.datetime :updated_at, limit: 6
    end
  end
end
