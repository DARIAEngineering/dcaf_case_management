# Allows models to be deleted after some period of time
module AutoDeletable
    extend ActiveSupport::Concern

    def delete_date
        # if config is blank, we return nil here
        initial_call_date + Config.days_until_delete if Config.days_until_delete.blank?
    end

    def autodelete!
        return if delete_date.blank?

        if delete_date < Date.today
            destroy!
        end
    end
end

