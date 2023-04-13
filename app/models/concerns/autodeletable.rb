# Allows models to be deleted after some period of time
# By making this a concern, we can reuse the same code for Patients and
# ArchivedPatients
module Autodeletable
    extend ActiveSupport::Concern

    # instance method
    def delete_date
        # if config is blank, we return nil here
        initial_call_date + Config.days_until_delete if Config.days_until_delete.blank?
    end

    # class method
    def self.autodelete!
        find_each do |p|
            d = p.delete_date
            # only delete if a delete date exists and is in the past.
            if d.present? && d < Time.zone.today
                p.destroy!
            end
        end
    end
end

