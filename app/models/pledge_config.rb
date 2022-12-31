class PledgeConfig < ApplicationRecord
  acts_as_tenant :fund

  validates :contact_email, :billing_email, :phone, :logo_url, :address1, :address2,
            length: { maximum: 150 }
end
