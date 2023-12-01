# Allows models to be deleted after some period of time
# By making this a concern, we can reuse the same code for Patients and
# ArchivedPatients
module Autodeletable
    extend ActiveSupport::Concern

    # instance method
    def delete_date
        # if config is blank, we return nil here
        initial_call_date + Config.days_until_delete if Config.days_until_delete.present?
    end

    # This funny business allows us to call both Patient.autodelete! and
    # ArchivedPatient.autodelete! without any extra code
    # 
    # (Any modules that include this Concern will get all methods in the
    # ClassMethods module, below, as new class methods of their own!)
    def self.included(base)
        base.extend(ClassMethods)
    end

    module ClassMethods
        def autodelete!
            find_each do |p|
                d = p.delete_date
                # only delete if a delete date exists and is in the past.
                p.destroy! if d.present? && d < Time.zone.today
            end
        end
    end
end

