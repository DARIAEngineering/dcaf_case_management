module Reporting
  class Patient
    class << self
      def contacted_for_line(line, start_date, end_date)
        ::Patient.where(_line: line).inject(0) do |count, patient|
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
        ::Patient.where(_line: line).inject(0) do |count, patient|
          first_reached_call = patient.calls.where(status: 'Reached patient').order(created_at: 'asc').first

          if first_reached_call && first_reached_call.created_at >= start_date && first_reached_call.created_at <= end_date
            count += 1
          end

          count
        end
      end

      def pledges_sent_for_line(line, start_date, end_date)
        ::Patient.where(_line: line).inject(0) do |count, patient|
          if patient.pregnancy.try(:pledge_sent)
            if patient.pregnancy.updated_at > start_date && patient.pregnancy.updated_at < end_date
              count += 1
            end
          end

          count
        end
      end

      def fulfillment_by_line
        map = %Q{
          function() {
            if (this.pregnancy.pledge_sent) {
              emit(this._line, { patient_id: this._id, fulfilled: this.fulfillment.fulfilled });
            }
          }
        }

        reduce = %Q{
          function(key, values) {
            var result = {
              line: key,
              fulfilled_count: 0,
              pledged_count: 0
            };

            values.forEach(function(value) {
              result.pledged_count += 1;

              if (value.fulfilled) {
                result.fulfilled_count += 1;
              }
            });

            return result;
          }
        }

        finalize = %Q{
          function (key, reducedVal) {
            reducedVal.rate = reducedVal.fulfilled_count/reducedVal.pledged_count;
            return reducedVal;
          };
        }

        results = Patient.map_reduce(map, reduce).out(inline: 1).finalize(finalize)
      end
    end
  end
end
