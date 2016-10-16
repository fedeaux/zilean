class CreateReportActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :report_activities do |t|
      t.belongs_to :report, foreign_key: true
      t.belongs_to :activity, foreign_key: true
    end
  end
end
