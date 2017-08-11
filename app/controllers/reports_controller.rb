# Controller for automatically generated service reporting across lines.
class ReportsController < ApplicationController
  def index; end

  def report
    case params[:timeframe]
    when 'weekly'
      @report = Reports::LineSummary.generate(1.week.ago, Time.zone.today)
    when 'monthly'
      @report = Reports::LineSummary.generate(1.month.ago, Time.zone.today)
    when 'yearly'
      @report = Reports::LineSummary.generate(1.year.ago, Time.zone.today)
    else
      @report = :invalid_timeframe
    end

    render head 406 if @report == :invalid_timeframe

    respond_to do |format|
      format.js do
        render partial: 'patient_report',
               locals: { report: @report,
                         lines: LINES,
                         timeframe: params[:timeframe] }
      end
    end
  end
end
