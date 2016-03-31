class CreateSchedules < ActiveRecord::Migration
  def change
   create_table :schedules do |t|
      t.string :title
      t.string :description
      t.date :date
      t.time :starttime
      t.time :endtime
      t.references :user, index: true
      t.string :class_name, :limit => 12

      t.timestamps
    end
  end
end
