class Pregnancy
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::History

	# relationships
	belongs_to :patient
	belongs_to :user
	embeds_many :pledges
	embeds_many :notes
	embeds_many :calls
	has_one :clinic

	# for mass posting
	accepts_nested_attributes_for :patient
	accepts_nested_attributes_for :clinic

	field :initial_call_date, type: DateTime
	field :status, type: String #enumeration
	field :last_menstrual_period_lmp_type, type: Integer
	field :last_menstrual_period_weeks, type: Integer
	field :last_menstrual_period_time, type: DateTime
	field :referred_by, type: String
	field :special_circumstances, type: String #ennumeration

	field :voicemail_ok, type: Boolean

	field :line, type: String #DC, MD, VA
	field :language, type: String

	# patient general info
	field :age, type: Integer
	field :city, type: String
	field :state, type: String #ennumeration?
	field :zip, type: String
	field :county, type: String
	field :race_ethnicity, type: String
	field :employment_status, type: String
	field :household_size, type: Integer
	field :insurance, type: String
	field :income, type: Integer

	field :appointment_date, type: Date
	# procedure info
	field :fax_received, type: Boolean
	field :procedure_cost, type: Integer
	field :procedure_date, type: DateTime
	field :procedure_completed_date, type: DateTime
	field :urgent_flag, type: Boolean

	# Mongoid history for users

	def self.most_recent
    order('created_at DESC').limit(1).first
  end

	def recent_calls
		calls.order("created_at DESC").limit(10)
	end

	def old_calls
		calls.order("created_at DESC") - calls.order("created_at DESC").limit(10)
	end

end
