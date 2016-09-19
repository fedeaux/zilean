class RenameTrackersToMetricsOnReports < ActiveRecord::Migration[5.0]
  def change
    rename_column :reports, :trackers, :metrics
  end
end
