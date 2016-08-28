class AddAncestryToActivity < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :ancestry, :string
  end
end
