class Fund < ApplicationRecord
  # TODO make papertrailable

  # Validations
  validates :name,
            :subdomain,
            :domain,
            presence: true,
            uniqueness: true
end
