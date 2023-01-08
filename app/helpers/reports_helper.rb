module ReportsHelper
  def report_url
    "https://datastudio.google.com/embed/reporting/#{ENV.fetch('DATASTUDIO_REPORT_URL', '')}"
  end
end
