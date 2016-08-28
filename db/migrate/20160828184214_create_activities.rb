class CreateActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :activities do |t|
      t.string :name
      t.string :slug
      t.string :color
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
