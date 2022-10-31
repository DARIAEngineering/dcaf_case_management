class PledgeConfig < ApplicationRecord
  acts_as_tenant :fund

  validates_presence_of :contact_email,
                        :billing_email,
                        :phone,
                        :address1,
                        :address2
  validates :contact_email, :billing_email, :phone, :logo_url, :address1, :address2,
            length: { maximum: 150 }
end
