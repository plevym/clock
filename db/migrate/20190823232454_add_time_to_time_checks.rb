class AddTimeToTimeChecks < ActiveRecord::Migration[5.2]
  def change
    change_table :time_checks do |t|
      t.datetime :time_checked, limit: 6
    end
  end
end
