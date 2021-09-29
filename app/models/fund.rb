class Fund < ApplicationRecord
  # Concerns
  # include PaperTrailable

  # Validations
  validates :name,
            :subdomain,
            :domain,
            :full_name,
            :site_domain,
            :phone,
            presence: true
end
