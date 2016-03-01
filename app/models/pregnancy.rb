class Pregnancy
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::History

	field :voicemail_ok, type: Boolean

	field :line, type: String #DC, MD, VA
	field :language, type: String
	field :pregnancy_id, type: String
	field :initial_call_date, type: DateTime
	field :pregnancy_status, type: String #enumeration
	field :last_menstrual_period_lmp_type, type: Integer
	field :last_menstrual_period_time, type: DateTime
	field :city, type: String
	field :state, type: String #ennumeration?
	field :county, type: String
	field :age, type: Integer
	field :race_ethnicity, type: String
	field :employment_status, type: String
	field :household_size, type: Integer
	field :insurance, type: String
	field :income, type: Integer
	field :referred_by, type: String
	field :special_circumstances, type: String #ennumeration
	field :fax_received, type: Boolean
	field :procedure_cost, type: Integer
	field :procedure_date, type: DateTime
	field :procedure_completed_date, type: DateTime
	field :urgent_flag, type: Boolean

	belongs_to :patient
	belongs_to :user
	embeds_many :pledges
	embeds_many :notes
	embeds_many :calls
	has_one :clinic

	# Mongoid history for users

	def self.most_recent
    order('created_at DESC').limit(1).first
  end

end
