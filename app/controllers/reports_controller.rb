class ReportsController < ApplicationController
  def index
    @weekly_report = Reports::LineSummary.generate(1.week.ago, Date.today)
  end
end
