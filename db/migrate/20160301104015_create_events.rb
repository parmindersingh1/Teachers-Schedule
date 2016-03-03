class CreateEvents < ActiveRecord::Migration
  def change
   create_table :events do |t|
      t.string :title
      t.string :description
      t.datetime :starttime
      t.datetime :endtime
      # t.boolean :all_day, :default => false
      t.references :user, index: true
      t.string :location
      # t.string :time_zone

      t.timestamps
    end
  end
end
