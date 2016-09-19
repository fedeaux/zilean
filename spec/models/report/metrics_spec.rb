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
        report = create :report, metrics: [ReportMetrics::FinishTime], activities: [create_or_find_activity(:activity_sleep)]
        expect(report.metrics_results[:finish_time][:average_formatted]).to eq '05:43'
      end

      it 'can eval mean finish time, mean duration and total duration, constraining weekdays' do
        create_sleep_log_entries_spanning_ten_days
        report = create :report, metrics: [ReportMetrics::FinishTime, ReportMetrics::TotalDuration, ReportMetrics::MeanDuration],
          activities: [create_or_find_activity(:activity_sleep)],
          weekdays: [0, 6]

        metrics_results = report.metrics_results

        expect(metrics_results[:finish_time][:average_formatted]).to eq '05:00'
        expect(metrics_results[:finish_time][:average_in_seconds]).to eq 18000.0

        expect(metrics_results[:total_duration][:in_seconds]).to eq 145800.0
        expect(metrics_results[:total_duration][:formatted]).to eq '16h30min'

        expect(metrics_results[:mean_duration][:in_seconds]).to eq 29160.0
        expect(metrics_results[:mean_duration][:formatted]).to eq '8h6min'
      end

      it 'can create an hierarchy when multiple activities are given' do
        create_work_log_entries_spanning_ten_days
        report = create :report, metrics: [ReportMetrics::TotalDuration, ReportMetrics::MeanDuration],
          activities: [create_or_find_activity(:activity_work)],
          weekdays: [1, 2, 3, 4, 5]

        metrics_results = report.metrics_results
        ap metrics_results
      end
    end
  end
end
