module Reporting
  class Patient
    class << self
      def contacted_for_line(line, start_date, end_date)
        ::Patient.where(_line: line).inject(0) do |acc, patient|
          eligible_calls = patient
            .calls
            .where(created_at: (start_date..end_date))
            .where(status: 'Reached patient')
            .count

          if eligible_calls > 0
            acc += 1
          end

          acc
        end
      end

      def new_contacted_for_line(line, start_date, end_date)
        ::Patient.where(_line: line).inject(0) do |acc, patient|
          first_reached_call = patient.calls.where(status: 'Reached patient').order(created_at: 'asc').first

          if first_reached_call && first_reached_call.created_at >= start_date && first_reached_call.created_at <= end_date
            acc += 1
          end

          acc
        end
      end

      def pledges_sent_for_line(line, start_date, end_date)
        ::Patient.where(_line: line).inject(0) do |acc, patient|
          if patient.pregnancy.try(:pledge_sent)
            if patient.pregnancy.updated_at > start_date && patient.pregnancy.updated_at < end_date
              acc += 1
            end
          end

          acc
        end
      end
    end
  end
end
