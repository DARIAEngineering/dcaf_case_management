class Pledge
	include Mongoid::Document

	field :pledge_type, type: String #soft/patient/naf/other/final_dcaf
	field :amount, type: Integer
	field :other_pledge_identifier, type: String
	field :sent, type: DateTime #validate presence when type is final
	field :sent_by, type: String #validate presence when type is final
	field :paid, type: Boolean #validate presence when type is final
	field :paid_date, type: DateTime #validate presence when type is final

	embedded_in :pregnancy

end
