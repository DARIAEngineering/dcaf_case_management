class Fund < ApplicationRecord
  # TODO make papertrailable

  # Validations
  validates :name,
            :subdomain,
            :domain,
            presence: true
  validates :name, :subdomain, uniqueness: true
end
