class Pregnancy
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  include LastMenstrualPeriodHelper

  # Relationships
  embedded_in :patient

  # Fields
  # Intake information
  field :last_menstrual_period_weeks, type: Integer
  field :last_menstrual_period_days, type: Integer

  # General patient information
  field :special_circumstances, type: String # TODO change to a has_many through

  # Procedure result - generally for administrative use
  field :fax_received, type: Boolean
  field :procedure_cost, type: Integer
  field :procedure_date, type: DateTime
  field :procedure_completed_date, type: DateTime
  field :resolved_without_dcaf, type: Boolean

  # Temp fields associated with pledges: TEMPORARY
  field :patient_contribution, type: Integer
  field :naf_pledge, type: Integer
  field :dcaf_soft_pledge, type: Integer
  field :pledge_sent, type: Boolean

  # Validations
  validates :created_by,
            presence: true

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'

  # Methods - see also the helpers

  # def pledge_status?(status)
  #   pledges.each do |pledge|
  #     return true if pledge[status]
  #   end
  #   false
  # end
end
