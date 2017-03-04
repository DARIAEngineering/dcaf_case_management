module Reporting
  class Patient
    class << self
      def contacted_for_line(line, start_date, end_date)
        ::Patient.where(_line: line).count
      end

      def new_contacted_for_line(line, start_date, end_date)
        ::Patient.where(_line: line).count
      end

      def pledges_sent_for_line(line, start_date, end_date)
        ::Patient.where(_line: line).inject(0) do |acc, patient|
          if patient.pregnancy.pledge_sent
            acc += (patient.pregnancy.dcaf_soft_pledge || 0)
          end

          acc
        end
      end
    end
  end
end
