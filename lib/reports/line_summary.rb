module Reports
  module LineSummary
    class << self
      def generate(date_start, date_end)
        LINES.inject({}) do |acc, line|
          acc[line] = subreport_for_line(line, date_start, date_end)

          acc
        end
      end

      private

      def subreport_for_line(line, date_start, date_end)
        {
          name: line,
          patients_contacted: Reporting::Patient.contacted_for_line(line, date_start, date_end),
          new_patients_contacted: Reporting::Patient.new_contacted_for_line(line, date_start, date_end),
          pledges_sent: Reporting::Patient.pledges_sent_for_line(line, date_start, date_end)
        }
      end
    end
  end
end
