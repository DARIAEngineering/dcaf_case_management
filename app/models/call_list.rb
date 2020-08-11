# Bridge class between patient and user.
class CallList < ApplicationRecord
  belongs_to :user
  belongs_to :patient
end
