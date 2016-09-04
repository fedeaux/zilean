class AddPathNamesToActivity < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :path_names, :string
  end
end
