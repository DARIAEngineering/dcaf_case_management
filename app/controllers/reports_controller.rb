class ReportsController < ApplicationController
  def index
    gon.weekly_report = Reports::LineSummary.generate(1.week.ago, Date.today)
    gon.monthly_report = Reports::LineSummary.generate(1.month.ago, Date.today)
    gon.yearly_report = Reports::LineSummary.generate(1.year.ago, Date.today)
  end
end
