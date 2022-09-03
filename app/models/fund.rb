class Fund < ApplicationRecord
  # TODO make papertrailable

  # Relations
  has_many :lines
  has_one :pledge_config

  # Validations
  validates :name,
            :subdomain,
            :domain,
            :full_name,
            :site_domain,
            :phone,
            presence: true
  validates :name, :subdomain, uniqueness: true
end
