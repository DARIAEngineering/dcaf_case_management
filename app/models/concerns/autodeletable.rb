# Allows models to be deleted after some period of time
module AutoDeletable
    extend ActiveSupport::Concern

    def delete_date
        if Config.days_until_delete.blank?
            initial_call_date + Config.days_until_delete
        else
            nil
        end
    end

    def autodelete!
        return if delete_date.blank?

        if delete_date < Date.today
            destroy!
        end
    end
end

