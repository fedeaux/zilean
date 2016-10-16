class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.belongs_to :user, foreign_key: true
      t.text :trackers, array: true, default: []
      t.text :weekdays, array: true, default: []
      t.datetime :start, default: nil
      t.datetime :finish, default: nil

      t.timestamps
    end
  end
end
