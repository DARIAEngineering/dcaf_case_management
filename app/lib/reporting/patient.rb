module Reporting
  class Patient
    class << self
      def contacted_for_line(line, start_date, end_date)
        ::Patient.where(line: line).inject(0) do |count, patient|
          eligible_calls = patient
            .calls
            .where(created_at: (start_date..end_date))
            .where(status: 'Reached patient')
            .count

          if eligible_calls > 0
            count += 1
          end

          count
        end
      end

      def new_contacted_for_line(line, start_date, end_date)
        ::Patient.where(line: line).inject(0) do |count, patient|
          first_reached_call = patient.calls.where(status: 'Reached patient').order(created_at: 'asc').first

          if first_reached_call && first_reached_call.created_at >= start_date && first_reached_call.created_at <= end_date
            count += 1
          end

          count
        end
      end

      def pledges_sent_for_line(line, start_date, end_date)
        ::Patient.where(line: line).inject(0) do |count, patient|
          if patient.pledge_sent
            if patient.updated_at > start_date && patient.updated_at < end_date
              count += 1
            end
          end

          count
        end
      end
    end
  end
end
