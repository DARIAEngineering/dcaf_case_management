module Reports
  module Fulfillment
    class << self
      def generate
        {
          fulfillment_by_line: Reporting::Patient.fulfillment_by_line,
          fulfillment_by_clinic: Reporting::Patient.fulfillment_by_clinic
        }
      end
    end
  end
end
