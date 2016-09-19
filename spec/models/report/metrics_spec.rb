require 'rails_helper'

RSpec.describe Report, type: :model do
  describe 'metrics' do
    let(:report) { create :report }

    context 'adding and removing' do
      it 'starts with no metrics' do
        expect(report.metrics).to be_empty
      end

      it 'can be set metrics by strings or object' do
        report.metrics = ['FinishTime']
        expect(report.metrics).to include ReportMetrics::FinishTime

        report.metrics = ['ReportMetrics::FinishTime']
        expect(report.metrics).to include ReportMetrics::FinishTime

        report.metrics = [ReportMetrics::FinishTime]
        expect(report.metrics).to include ReportMetrics::FinishTime
      end
    end

    context 'applying metrics' do
      it 'can eval mean finish time' do
        create_sleep_log_entries_spanning_ten_days
        report = create :report, metrics: [ReportMetrics::FinishTime], activities: [create_or_find_activity(:activity_sleep)]
        expect(report.metrics_results[:finish_time][:average_formatted]).to eq '05:43'
      end

      it 'can eval mean finish time, mean duration and total duration, constraining weekdays' do
        create_sleep_log_entries_spanning_ten_days
        report = create :report, metrics: [ReportMetrics::FinishTime, ReportMetrics::TotalDuration],
          activities: [create_or_find_activity(:activity_sleep)],
          weekdays: [0, 6]

        metrics_results = report.metrics_results

        expect(metrics_results[:finish_time][:average_formatted]).to eq '05:00'
        expect(metrics_results[:finish_time][:average_in_seconds]).to eq 18000.0

        expect(metrics_results[:duration][:in_seconds]).to eq 145800.0
        expect(metrics_results[:duration][:formatted]).to eq '16h30min'
      end
    end
  end
end
