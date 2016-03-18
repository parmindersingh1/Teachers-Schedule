class CreateEvents < ActiveRecord::Migration
  def change
   create_table :events do |t|
      t.string :title
      t.string :description
      t.date :date
      t.time :starttime
      t.time :endtime
      # t.boolean :all_day, :default => false
      t.references :user, index: true
      t.string :location
      # t.string :time_zone

      t.timestamps
    end
  end
end
