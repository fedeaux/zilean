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
  end
end
