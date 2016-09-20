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

    context 'metrics helpers' do
      it 'can format duration' do
        metric = ReportMetrics::Base.new

        expect(metric.format_duration(90)).to eq '1min'
        expect(metric.format_duration(5*60*60 + 30*60)).to eq '5h30min'
        expect(metric.format_duration(2*24*60*60 + 5*60*60)).to eq '2d5h'
        expect(metric.format_duration(10*24*60*60 + 5*60*60)).to eq '1w3d5h'
        expect(metric.format_duration(50*24*60*60 + 9*60*60)).to eq '1M2w6d'
        expect(metric.format_duration(450*24*60*60 + 9*60*60 + 15*60)).to eq '1Y3M'
        expect(metric.format_duration(12*30*24*60*60 + 8*24*60*60 + 15*60)).to eq '1Y'
      end
    end

    context 'applying metrics' do
      it 'can eval mean finish time' do
        create_sleep_log_entries_spanning_ten_days
        activity = create_or_find_activity :activity_sleep
        report = create :report, metrics: [ReportMetrics::FinishTime], activities: [activity]
        expect(report.metrics_results[activity.id].metrics['ReportMetrics::FinishTime'][:average_formatted]).to eq '05:43'
      end

      it 'can eval mean finish time, mean duration and total duration, constraining weekdays' do
        create_sleep_log_entries_spanning_ten_days

        activity = create_or_find_activity(:activity_sleep)

        # ReportMetrics::TotalDuration is added as an dependency of ReportMetrics::MeanDuration
        report = create :report, metrics: [ReportMetrics::FinishTime, ReportMetrics::MeanDuration],
          activities: [activity],
          weekdays: [0, 6]

        activity_metrics = report.metrics_results[activity.id].metrics

        expect(activity_metrics["ReportMetrics::FinishTime"]).
          to eq ({:average_in_seconds=>18000.0, :average_formatted=>"05:00"})

        expect(activity_metrics["ReportMetrics::TotalDuration"]).
          to eq ({:in_seconds=>145800.0, :formatted=>"1d16h30min"})
      end

      # it 'can create an hierarchy when multiple activities are given' do
      #   create_work_log_entries_spanning_ten_days

      #   report = create :report, metrics: [ReportMetrics::TotalDuration, ReportMetrics::MeanDuration],
      #     activities: [create_or_find_activity(:activity_work)],
      #     weekdays: [1, 2, 3, 4, 5]

      #   metrics_results = report.metrics_results
      #   ap metrics_results
      # end
    end
  end
end
