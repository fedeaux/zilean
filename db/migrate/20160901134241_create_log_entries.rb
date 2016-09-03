class CreateLogEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :log_entries do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :activity, foreign_key: true
      t.datetime :started_at
      t.datetime :finished_at
      t.text :observations

      t.timestamps
    end
  end
end
