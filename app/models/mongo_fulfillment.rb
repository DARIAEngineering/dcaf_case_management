# Indicator that a pledge by the primary fund was cashed in,
# which in turn indicates that the patient used our pledged money.
class MongoFulfillment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  store_in collection: 'fulfillments'

  # Relationships
  embedded_in :can_fulfill, polymorphic: true

  field :fulfilled, type: Boolean
  field :procedure_date, type: Date
  field :gestation_at_procedure, type: String
  field :fund_payout, type: Integer
  field :check_number, type: String
  field :date_of_check, type: Date
  field :audited, type: Boolean

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'

end
# PORTED
