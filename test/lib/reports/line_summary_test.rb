require 'test_helper'
require 'set'
class LineSummaryReportTest < ActiveSupport::TestCase
  describe '.generate' do

    it 'should return a hash with a key for each line' do
      report = Reports::LineSummary.generate(Date.today - 1.day, Date.today)

      LINES.each do |line|
        refute_nil report[line]
      end
    end

    it 'should return the expected metrics for each line' do
      report = Reports::LineSummary.generate(Date.today - 1.day, Date.today)

      LINES.each do |line|
        assert report[line].keys.to_set.superset?(%i(patients_contacted new_patients_contacted pledges_sent).to_set)
      end
    end
  end
end
