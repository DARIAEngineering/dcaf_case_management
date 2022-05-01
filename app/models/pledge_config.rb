class PledgeConfig < ApplicationRecord
  acts_as_tenant :fund

  validates_presence_of :contact_email,
                        :billing_email,
                        :phone,
                        :address1,
                        :address2
end
