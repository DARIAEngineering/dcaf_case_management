# Concern Auditable for Models
module Auditable
 extend ActiveSupport::Concern
  
 track_history on: fields.keys + [:updated_by_id],
               version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
